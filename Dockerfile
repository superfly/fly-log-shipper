FROM golang:1.21 as builder

WORKDIR /app
COPY vector-monitor.go .
RUN go mod init vector-monitor
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o vector-monitor .

FROM timberio/vector:0.33.0-debian
COPY vector-configs /etc/vector/
COPY ./start-fly-log-transporter.sh .
COPY --from=builder /app/vector-monitor /usr/local/bin/

CMD ["bash", "start-fly-log-transporter.sh"]
ENTRYPOINT []
