FROM golang:1.17 as flylogs
WORKDIR /go/src/github.com/superfly/fly-log-stream

ENV BUILD_DEPS="gettext"  \
    RUNTIME_DEPS="libintl" \
    GO111MODULE=on
COPY . .
RUN go get
RUN CGO_ENABLED=0 GOOS=linux go build -v -o fly-logs main.go


RUN curl --proto '=https' --tlsv1.2 -sSf -o /tmp/install_vector.sh https://sh.vector.dev
RUN sh /tmp/install_vector.sh -y

FROM ubuntu:20.04

RUN mkdir -p /etc/vector
COPY . .
COPY vector-configs/* /etc/vector/ 
RUN apt-get update && apt-get install -y socat ca-certificates
COPY --from=flylogs /root/.vector/bin/vector /usr/local/bin/vector
COPY --from=flylogs /go/src/github.com/superfly/fly-log-stream/fly-logs /usr/local/bin/fly-logs
COPY --from=flylogs /etc/ssl/certs/* /etc/ssl/certs/
CMD ["bash", "start-fly-log-transporter.sh"]
