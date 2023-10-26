package main

import (
	"bytes"
	"encoding/json"
	"log"
	"net/http"
	"os/exec"
	"os"
	"strconv"
	"time"
)

const (
	vectorAPIURL      = "http://localhost:8686/graphql"
	defaultInactivityTimeout = 10
	vectorExecutable  = "vector" // path to the Vector executable if not in $PATH
)

type GraphqlRequest struct {
	Query string `json:"query"`
}

type GraphqlResponse struct {
	Data struct {
		Metrics struct {
			ProcessedEventsTotal float64 `json:"processedEventsTotal"`
		} `json:"metrics"`
	} `json:"data"`
}

func getInactivityTimeout() time.Duration {
	timeout := defaultInactivityTimeout

	// Read the environment variable
	if value, exists := os.LookupEnv("INACTIVITY_TIMEOUT"); exists {
		if intValue, err := strconv.Atoi(value); err == nil && intValue > 0 {
			timeout = intValue
		} else {
			log.Printf("Warning: Invalid INACTIVITY_TIMEOUT value, using default %d seconds", defaultInactivityTimeout)
		}
	}

	return time.Duration(timeout) * time.Second
}

func getProcessedEvents() (float64, error) {
	payload := GraphqlRequest{
		Query: `
		{
			metrics {
				processedEventsTotal
			}
		}`,
	}

	body, err := json.Marshal(payload)
	if err != nil {
		return 0, err
	}

	resp, err := http.Post(vectorAPIURL, "application/json", bytes.NewBuffer(body))
	if err != nil {
		return 0, err
	}
	defer resp.Body.Close()

	var result GraphqlResponse
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return 0, err
	}

	return result.Data.Metrics.ProcessedEventsTotal, nil
}

func restartVector() {
	cmd := exec.Command(vectorExecutable)
	if err := cmd.Start(); err != nil {
		log.Fatalf("Error restarting Vector: %v", err)
	}
	log.Println("Vector restarted.")
}

func main() {
	var previousCount float64
	lastActivityTime := time.Now()
	var inactivityTimeout = getInactivityTimeout()
	log.Println("Vector monitor started with threshold of %s seconds of inactivity.", inactivityTimeout)
	for {
		time.Sleep(inactivityTimeout * time.Second)

		currentCount, err := getProcessedEvents()
		if err != nil {
			log.Printf("Error retrieving event count: %v", err)
			continue
		}

		if currentCount != previousCount {
			lastActivityTime = time.Now()
		} else if time.Since(lastActivityTime) > inactivityTimeout {
			log.Println("No new logs processed for the specified duration. Restarting Vector.")
			restartVector()
			lastActivityTime = time.Now() // Reset the timer after restart
		}

		previousCount = currentCount
	}
}
