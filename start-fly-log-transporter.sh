#!/bin/bash
set -e

[[ ! -z "$DATADOG_API_KEY" ]] && cat /etc/vector/datadog.toml >> /etc/vector/vector.toml
if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_BUCKET" ]; then
  cat /etc/vector/aws_s3.toml >> /etc/vector/vector.toml
  [[ -n "$S3_ENDPOINT" ]] && echo "  endpoint = \"${S3_ENDPOINT}\"" >> /etc/vector/vector.toml
fi
[[ -n "$HONEYCOMB_API_KEY" ]] && cat /etc/vector/honeycomb.toml >> /etc/vector/vector.toml
[[ -n "$HUMIO_TOKEN" ]] && cat /etc/vector/humio.toml >> /etc/vector/vector.toml
[[ -n "$LOGDNA_API_KEY" ]] && cat /etc/vector/logdna.toml >> /etc/vector/vector.toml
if [ -n "$NEW_RELIC_INSERT_KEY" ] || [ -n "$NEW_RELIC_LICENSE_KEY" ]; then
  cat /etc/vector/new_relic.toml >> /etc/vector/vector.toml
  [[ -n "$NEW_RELIC_INSERT_KEY" ]] && echo "  insert_key = \"${NEW_RELIC_INSERT_KEY}\"" >> /etc/vector/vector.toml
  [[ -n "$NEW_RELIC_LICENSE_KEY" ]] && echo "  license_key = \"${NEW_RELIC_LICENSE_KEY}\"" >> /etc/vector/vector.toml
fi
[[ -n "$PAPERTRAIL_ENDPOINT" ]] && cat /etc/vector/papertrail.toml >> /etc/vector/vector.toml
[[ -n "$SEMATEXT_TOKEN" ]] && cat /etc/vector/sematext.toml >> /etc/vector/vector.toml
[[ -n "$UPTRACE_API_KEY" ]] && [[ -n "$UPTRACE_PROJECT" ]] && cat /etc/vector/uptrace.toml >> /etc/vector/vector.toml
[[ -n "$LOGTAIL_TOKEN" ]] && cat /etc/vector/logtail.toml >> /etc/vector/vector.toml
[[ -n "$LOGFLARE_API_KEY" ]] && [[ -n "$LOGFLARE_SOURCE_TOKEN" ]] && cat /etc/vector/logflare.toml >> /etc/vector/vector.toml
[[ -n "$ERASEARCH_URL" ]] && [[ -n "$ERASEARCH_INDEX" ]] && [[ -n "$ERASEARCH_AUTH" ]] && cat /etc/vector/erasearch.toml >> /etc/vector/vector.toml
[[ -n "$LOKI_URL" ]] && [[ -n "$LOKI_USERNAME" ]] && [[ -n "$LOKI_PASSWORD" ]] && cat /etc/vector/loki.toml >> /etc/vector/vector.toml

exec vector -c /etc/vector/vector.toml
