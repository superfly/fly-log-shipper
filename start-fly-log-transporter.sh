#!/bin/bash
set -euo pipefail

BASEDIR=`dirname "$0"`
. "$BASEDIR/common.sh"

${BASEDIR}/sources-from-env.sh

echo 'Configured loggers:'
find /etc/vector/app-loggers -type f -exec basename -s '.toml' {} \;

exec vector --watch-config -c /etc/vector/vector.toml -C /etc/vector/app-loggers
