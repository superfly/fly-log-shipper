#!/bin/bash
set -euo pipefail

BASEDIR=`dirname "$0"`
. "$BASEDIR/common.sh"

APP=$1
PROVIDER=$2

rm /etc/vector/app-loggers/source_${APP}.toml
rm /etc/vector/app-loggers/sink_${PROVIDER}_${APP}.toml