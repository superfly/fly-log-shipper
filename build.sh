#!/bin/bash

set -e

IMAGE=flyio/log-shipper:auto-$(git rev-parse --short HEAD)
docker build --platform linux/amd64 -t $IMAGE .
docker push $IMAGE
