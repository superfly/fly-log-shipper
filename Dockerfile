FROM golang:1.15.7-buster
WORKDIR /go/src/github.com/superfly/fly-log-stream

ENV BUILD_DEPS="gettext"  \
    RUNTIME_DEPS="libintl" \
    GO111MODULE=on

COPY . .
RUN mkdir -p /etc/vector
COPY vector-configs/* /etc/vector/
RUN curl --proto '=https' --tlsv1.2 -sSf -o /tmp/install_vector.sh https://sh.vector.dev 
RUN apt-get update && apt-get install -y socat
RUN go get
RUN CGO_ENABLED=0 GOOS=linux go build -v -o /usr/local/bin/fly-logs main.go
RUN sh /tmp/install_vector.sh -y
RUN cp /root/.vector/bin/vector /usr/local/bin/vector
CMD bash start-fly-log-transporter.sh
