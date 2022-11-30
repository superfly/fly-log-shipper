#!/bin/bash
set -e

if [ ! -z "$DATADOG_API_KEY" ]; then 
   cat /etc/vector/datadog.toml >> /etc/vector/vector.toml
fi
if [ ! -z "$AWS_ACCESS_KEY_ID" ] && [ ! -z "$AWS_BUCKET" ]; then
  cat /etc/vector/aws_s3.toml >> /etc/vector/vector.toml 
  [[ ! -z "$S3_ENDPOINT" ]] && echo "  endpoint = \"${S3_ENDPOINT}\"" >> /etc/vector/vector.toml 
fi
[[ ! -z "$HONEYCOMB_API_KEY" ]] && cat /etc/vector/honeycomb.toml >> /etc/vector/vector.toml 
if [ ! -z "$HUMIO_TOKEN" ]; then
  cat /etc/vector/humio.toml >> /etc/vector/vector.toml
  [[ ! -z "$HUMIO_ENDPOINT" ]] && echo "  endpoint = \"${HUMIO_ENDPOINT}\"" >> /etc/vector/vector.toml
fi
[[ ! -z "$LOGDNA_API_KEY" ]] && cat /etc/vector/logdna.toml >> /etc/vector/vector.toml 
if [ ! -z "$NEW_RELIC_INSERT_KEY" ] || [ ! -z "$NEW_RELIC_LICENSE_KEY" ]; then
  cat /etc/vector/new_relic.toml >> /etc/vector/vector.toml 
  [[ ! -z "$NEW_RELIC_INSERT_KEY" ]] && echo "  insert_key = \"${NEW_RELIC_INSERT_KEY}\"" >> /etc/vector/vector.toml 
  [[ ! -z "$NEW_RELIC_LICENSE_KEY" ]] && echo "  license_key = \"${NEW_RELIC_LICENSE_KEY}\"" >> /etc/vector/vector.toml 
fi
[[ ! -z "$PAPERTRAIL_ENDPOINT" ]] && cat /etc/vector/papertrail.toml >> /etc/vector/vector.toml 
[[ ! -z "$SEMATEXT_TOKEN" ]] && cat /etc/vector/sematext.toml >> /etc/vector/vector.toml
[[ ! -z "$UPTRACE_API_KEY" ]] && [[ ! -z "$UPTRACE_PROJECT" ]] && cat /etc/vector/uptrace.toml >> /etc/vector/vector.toml
[[ ! -z "$LOGTAIL_TOKEN" ]] && cat /etc/vector/logtail.toml >> /etc/vector/vector.toml
[[ ! -z "$LOGFLARE_API_KEY" ]] && [[ ! -z "$LOGFLARE_SOURCE_TOKEN" ]] && cat /etc/vector/logflare.toml >> /etc/vector/vector.toml
[[ ! -z "$ERASEARCH_URL" ]] && [[ ! -z "$ERASEARCH_INDEX" ]] && [[ ! -z "$ERASEARCH_AUTH" ]] && cat /etc/vector/erasearch.toml >> /etc/vector/vector.toml
[[ ! -z "$LOKI_URL" ]] && [[ ! -z "$LOKI_USERNAME" ]] && [[ ! -z "$LOKI_PASSWORD" ]] && cat /etc/vector/loki.toml >> /etc/vector/vector.toml
[[ ! -z "$AXIOM_TOKEN" ]] && [[ ! -z "$AXIOM_DATASET" ]] && cat /etc/vector/axiom.toml >> /etc/vector/vector.toml

exec vector -c /etc/vector/vector.toml
