#!/bin/bash
set -e

cd /evolution

# Run the real Evolution API's original startup logic in the background,
# bound to the internal-only API_INTERNAL_PORT (SERVER_PORT is what the
# app itself reads to decide what port to bind).
export SERVER_PORT="${API_INTERNAL_PORT:-8081}"
( . ./Docker/scripts/deploy_database.sh && npm run start:prod ) &
API_PID=$!

# Run the public-facing redirect/proxy wrapper - this is what Railway's
# healthcheck and domain actually route to.
node /wrapper/proxy.js &
WRAPPER_PID=$!

wait -n "$API_PID" "$WRAPPER_PID"
