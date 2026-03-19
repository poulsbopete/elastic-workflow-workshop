#!/bin/bash
#
# Setup script for Challenge 2: Building a Detection Workflow
# Ensures workflow prerequisites are in place
#
# Supports both basic auth and API key (Serverless). When ELASTICSEARCH_API_KEY
# or ELASTICSEARCH_APIKEY is set, uses API key and creates indices without
# number_of_shards/number_of_replicas (Serverless-compatible).
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "${SCRIPT_DIR}/../../lib/auth.sh" ] && source "${SCRIPT_DIR}/../../lib/auth.sh"

ELASTICSEARCH_URL="${ELASTICSEARCH_URL:-http://localhost:9200}"
KIBANA_URL="${KIBANA_URL:-http://localhost:5601}"

# Default es_curl if auth.sh was not found
if ! type es_curl &>/dev/null; then
    es_curl() { curl -s "$@"; }
fi

echo "=============================================="
echo "Setting up Challenge 2: Building a Detection Workflow"
echo "=============================================="

# ----------------------------------------------
# Wait for Elasticsearch to be ready
# ----------------------------------------------
echo ""
echo "[1/4] Waiting for Elasticsearch..."
MAX_RETRIES=30
RETRY_COUNT=0

until es_curl "${ELASTICSEARCH_URL}/_cluster/health" 2>/dev/null | grep -q '"status":"green"\|"status":"yellow"'; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "ERROR: Elasticsearch did not become ready in time"
        exit 1
    fi
    echo "  Waiting... (attempt ${RETRY_COUNT}/${MAX_RETRIES})"
    sleep 5
done
echo "  Elasticsearch is ready!"

# ----------------------------------------------
# Wait for Kibana to be ready
# ----------------------------------------------
echo ""
echo "[2/4] Waiting for Kibana..."
MAX_RETRIES=30
RETRY_COUNT=0

until es_curl "${KIBANA_URL}/api/status" 2>/dev/null | grep -q '"level":"available"'; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "  Warning: Kibana may not be fully ready yet."
        break
    fi
    echo "  Waiting... (attempt ${RETRY_COUNT}/${MAX_RETRIES})"
    sleep 5
done
echo "  Kibana is ready!"

# ----------------------------------------------
# Create incidents index for workflow output
# Serverless: omit number_of_shards/number_of_replicas
# ----------------------------------------------
echo ""
echo "[3/4] Creating incidents index..."

if ! es_curl -o /dev/null -w "%{http_code}" "${ELASTICSEARCH_URL}/incidents" 2>/dev/null | grep -q "200"; then
    # Use mappings only when using API key (Serverless); otherwise include settings
    if [ -n "${SERVERLESS_AUTH}" ] && [ "${SERVERLESS_AUTH}" = "1" ]; then
        INC_BODY='{"mappings": {
            "properties": {
                "incident_id": { "type": "keyword" },
                "incident_type": { "type": "keyword" },
                "status": { "type": "keyword" },
                "severity": { "type": "keyword" },
                "business_id": { "type": "keyword" },
                "business_name": { "type": "text", "fields": { "keyword": { "type": "keyword" } } },
                "city": { "type": "keyword" },
                "metrics": { "type": "object", "properties": { "review_count": { "type": "integer" }, "avg_stars": { "type": "float" }, "avg_trust": { "type": "float" }, "unique_attackers": { "type": "integer" } } },
                "affected_review_ids": { "type": "keyword" },
                "detected_at": { "type": "date" },
                "created_at": { "type": "date" },
                "updated_at": { "type": "date" },
                "resolved_at": { "type": "date" },
                "resolution_notes": { "type": "text" },
                "resolved_by": { "type": "keyword" }
            }
        }}'
    else
        INC_BODY='{"settings": {"number_of_shards": 1, "number_of_replicas": 0}, "mappings": {
            "properties": {
                "incident_id": { "type": "keyword" },
                "incident_type": { "type": "keyword" },
                "status": { "type": "keyword" },
                "severity": { "type": "keyword" },
                "business_id": { "type": "keyword" },
                "business_name": {
                    "type": "text",
                    "fields": { "keyword": { "type": "keyword" } }
                },
                "city": { "type": "keyword" },
                "metrics": {
                    "type": "object",
                    "properties": {
                        "review_count": { "type": "integer" },
                        "avg_stars": { "type": "float" },
                        "avg_trust": { "type": "float" },
                        "unique_attackers": { "type": "integer" }
                    }
                },
                "affected_review_ids": { "type": "keyword" },
                "detected_at": { "type": "date" },
                "created_at": { "type": "date" },
                "updated_at": { "type": "date" },
                "resolved_at": { "type": "date" },
                "resolution_notes": { "type": "text" },
                "resolved_by": { "type": "keyword" }
            }
        }}'
    fi
    es_curl -X PUT "${ELASTICSEARCH_URL}/incidents" -H "Content-Type: application/json" -d "${INC_BODY}" > /dev/null
    echo "  incidents index created."
else
    echo "  incidents index already exists."
fi

# ----------------------------------------------
# Create notifications index for alerts
# ----------------------------------------------
echo ""
echo "[4/4] Creating notifications index..."

if ! es_curl -o /dev/null -w "%{http_code}" "${ELASTICSEARCH_URL}/notifications" 2>/dev/null | grep -q "200"; then
    if [ -n "${SERVERLESS_AUTH}" ] && [ "${SERVERLESS_AUTH}" = "1" ]; then
        NOTIF_BODY='{"mappings": {"properties": {"notification_id": {"type": "keyword"}, "notification_type": {"type": "keyword"}, "recipient_type": {"type": "keyword"}, "priority": {"type": "keyword"}, "title": {"type": "text"}, "message": {"type": "text"}, "business_id": {"type": "keyword"}, "incident_id": {"type": "keyword"}, "created_at": {"type": "date"}, "read": {"type": "boolean"}, "read_at": {"type": "date"}}}}'
    else
        NOTIF_BODY='{"settings": {"number_of_shards": 1, "number_of_replicas": 0}, "mappings": {"properties": {"notification_id": {"type": "keyword"}, "notification_type": {"type": "keyword"}, "recipient_type": {"type": "keyword"}, "priority": {"type": "keyword"}, "title": {"type": "text"}, "message": {"type": "text"}, "business_id": {"type": "keyword"}, "incident_id": {"type": "keyword"}, "created_at": {"type": "date"}, "read": {"type": "boolean"}, "read_at": {"type": "date"}}}}'
    fi
    es_curl -X PUT "${ELASTICSEARCH_URL}/notifications" -H "Content-Type: application/json" -d "${NOTIF_BODY}" > /dev/null
    echo "  notifications index created."
else
    echo "  notifications index already exists."
fi

# ----------------------------------------------
# Refresh indices
# ----------------------------------------------
es_curl -X POST "${ELASTICSEARCH_URL}/_refresh" > /dev/null

# ----------------------------------------------
# Final status
# ----------------------------------------------
echo ""
echo "=============================================="
echo "Challenge 2 Setup Complete!"
echo "=============================================="
echo ""
echo "Prerequisites ready:"
echo "  - incidents index: created"
echo "  - notifications index: created"
echo "  - Kibana Workflows app: accessible"
echo ""
echo "You can now create your Negative Review Campaign Detection workflow!"
echo ""
