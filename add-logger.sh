#!/bin/bash
set -euo pipefail

BASEDIR=`dirname "$0"`
. "$BASEDIR/common.sh"


APP=$1
PROVIDER=$2
export PROVIDER_TOKEN=$3
 template < /etc/vector/logger.toml > /etc/vector/app-loggers/source_${APP}.toml
 template < /etc/vector/sinks/$PROVIDER.toml > /etc/vector/app-loggers/sink_${PROVIDER}_${APP}.toml
