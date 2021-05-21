// Copyright 2012-2021 The NATS Authors
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"runtime"
	"time"

	"github.com/nats-io/nats.go"
)

func usage() {
	log.Printf("Usage: fly-logs\n")
	flag.PrintDefaults()
}

func showUsageAndExit(exitcode int) {
	usage()
	os.Exit(exitcode)
}

func printMsg(m *nats.Msg) {
	fmt.Println(string(m.Data))
}

func main() {
	var user = os.Getenv("ORG")
	var password = os.Getenv("ACCESS_TOKEN")
	var subject = os.Getenv("SUBJECT")
	var queue = os.Getenv("QUEUE")
	if subject == "" {
		subject = "logs.>"
	}
	var urls = fmt.Sprintf("nats://%s:%s@[fdaa::3]:4223", user, password)
	var showHelp = flag.Bool("h", false, "Show help message")

	log.SetFlags(0)
	flag.Usage = usage
	flag.Parse()

	if *showHelp {
		showUsageAndExit(0)
	}

	// Connect Options.
	opts := []nats.Option{nats.Name("Fly logs stream")}
	opts = setupConnOptions(opts)

	// Connect to NATS
	nc, err := nats.Connect(urls, opts...)
	if err != nil {
		log.Fatal(err)
	}

	if queue != "" {
		nc.QueueSubscribe(subject, queue, func(msg *nats.Msg) {
			printMsg(msg)
		})
	}
	nc.Subscribe(subject, func(msg *nats.Msg) {
		printMsg(msg)
	})
	nc.Flush()

	if err := nc.LastError(); err != nil {
		log.Fatal(err)
	}

	runtime.Goexit()
}

func setupConnOptions(opts []nats.Option) []nats.Option {
	totalWait := 10 * time.Minute
	reconnectDelay := time.Second
	ts := time.Now().Format(time.RFC3339)
	opts = append(opts, nats.ReconnectWait(reconnectDelay))
	opts = append(opts, nats.MaxReconnects(int(totalWait/reconnectDelay)))
	opts = append(opts, nats.DisconnectErrHandler(func(nc *nats.Conn, err error) {
		log.Printf("{\"timestamp\": \"%s\", \"level\": \"ERROR\", \"application\": \"fly-logs\", \"message\": \"Disconnected due to:%s, will attempt reconnects for %.0fm\"}", ts, err, totalWait.Minutes())
	}))
	opts = append(opts, nats.ReconnectHandler(func(nc *nats.Conn) {
		log.Printf("{\"timestamp\": \"%s\", \"level\": \"INFO\", \"application\": \"fly-logs\", \"message\": \"Reconnected [%s]\"}", ts, nc.ConnectedUrl())
	}))
	opts = append(opts, nats.ClosedHandler(func(nc *nats.Conn) {
		log.Fatalf("{\"timestamp\": \"%s\", \"level\": \"ERROR\", \"application\": \"fly-logs\", \"message\": \"Exiting: %v\"}", ts, nc.LastError())
	}))
	return opts
}
