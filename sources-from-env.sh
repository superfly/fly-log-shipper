#!/bin/bash
set -euo pipefail

BASEDIR=$(dirname "$0")

IFS=',' read -ra values <<< "$LOGGERS"

for value in "${values[@]}"; do
    echo "Adding logger for app ${arguments[0]} and provider ${arguments[1]}"
    IFS=':' read -ra arguments <<< "$value"
    "${BASEDIR}/add-logger.sh" "${arguments[@]}"
done