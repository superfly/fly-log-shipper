FROM golang:1.17 as flylogs

COPY . /build
WORKDIR /build

RUN go get
RUN CGO_ENABLED=0 go build -trimpath -o fly-logs main.go

FROM timberio/vector:latest-debian

RUN apt-get update \
  && apt-get install -yq socat \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists

COPY start-fly-log-transporter.sh /usr/local/bin/start-fly-log-transporter.sh
COPY vector-configs/* /etc/vector/ 
COPY --from=flylogs /build/fly-logs /usr/local/bin/fly-logs

# Clear the entrypoint set by Vector
ENTRYPOINT [ ]

CMD ["/usr/local/bin/start-fly-log-transporter.sh"]
