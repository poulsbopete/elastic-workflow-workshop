#!/bin/bash
#
# Shared auth helper for Instruqt challenge scripts.
# Source this file to get es_curl() that works with both:
#   - Basic auth (ELASTICSEARCH_USER + ELASTICSEARCH_PASSWORD)
#   - API key (ELASTICSEARCH_API_KEY or ELASTICSEARCH_APIKEY) for Serverless/Cloud
#
# Usage: source "$(dirname "$0")/../lib/auth.sh"   # from a challenge script
#

export ELASTICSEARCH_URL="${ELASTICSEARCH_URL:-http://localhost:9200}"
export KIBANA_URL="${KIBANA_URL:-http://localhost:5601}"

# Prefer API key (Serverless/Cloud); fall back to basic auth
CURL_ES_OPTS=()
if [ -n "${ELASTICSEARCH_API_KEY}" ] || [ -n "${ELASTICSEARCH_APIKEY}" ]; then
    API_KEY="${ELASTICSEARCH_API_KEY:-$ELASTICSEARCH_APIKEY}"
    CURL_ES_OPTS=(-H "Authorization: ApiKey ${API_KEY}")
elif [ -n "${ELASTICSEARCH_USER}" ] && [ -n "${ELASTICSEARCH_PASSWORD}" ]; then
    CURL_ES_OPTS=(-u "${ELASTICSEARCH_USER}:${ELASTICSEARCH_PASSWORD}")
fi

es_curl() {
    curl -s "${CURL_ES_OPTS[@]}" "$@"
}

# True if we're using API key (Serverless); used to skip number_of_shards etc.
if [ -n "${ELASTICSEARCH_API_KEY}" ] || [ -n "${ELASTICSEARCH_APIKEY}" ]; then
    export SERVERLESS_AUTH=1
else
    export SERVERLESS_AUTH=0
fi
