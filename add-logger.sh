#!/bin/bash
set -euo pipefail

BASEDIR=`dirname "$0"`
. "$BASEDIR/common.sh"

export PROVIDER_TOKEN=$1
APP=$2
PROVIDER=$3
export NATS_TOKEN=$4

 template < /etc/vector/logger.toml > /etc/vector/app-loggers/source_${APP}.toml
 template < /etc/vector/sinks/$PROVIDER.toml > /etc/vector/app-loggers/sink_${PROVIDER}_${APP}.toml
