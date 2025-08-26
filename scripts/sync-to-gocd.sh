#!/bin/bash
# Trigger GoCD to sync configuration from repository

GOCD_SERVER="${GOCD_SERVER:-http://localhost:8153}"
GOCD_USER="${GOCD_USER:-admin}"
GOCD_PASS="${GOCD_PASS:-admin123}"

echo "🔄 Triggering GoCD configuration sync..."

# Trigger config repository refresh
response=$(curl -s -w "%{http_code}" -X POST \
  -u "$GOCD_USER:$GOCD_PASS" \
  "$GOCD_SERVER/go/api/admin/config_repos/refresh" \
  -H "Accept: application/vnd.go.cd.v1+json")

http_code="${response: -3}"

if [ "$http_code" = "200" ]; then
    echo "✅ Sync triggered successfully. Check GoCD UI for updates."
else
    echo "❌ Sync failed with HTTP code: $http_code"
    echo "Response: ${response%???}"
    exit 1
fi
