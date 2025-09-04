#!/bin/sh

# Start script for nginx interface container
# This script substitutes environment variables in OpenAPI spec and starts nginx

set -e

echo "📝 Substituting OpenAPI Spec environment variables:"
echo "- API_GATEWAY_URL: $API_GATEWAY_URL"

envsubst < /usr/share/nginx/html/openapi.yaml > /tmp/openapi.yaml.tmp
mv /tmp/openapi.yaml.tmp /usr/share/nginx/html/openapi.yaml

echo "✅ Environment variable substitution complete"
echo "🚀 Starting nginx..."
exec nginx -g "daemon off;"