#!/bin/bash

set -e

docker build --platform linux/amd64 -t flyio/log-shipper:auto .
docker push flyio/log-shipper:auto
