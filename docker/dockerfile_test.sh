#!/usr/bin/env bash
set -euo pipefail

# ----------------------------
# Config
# ----------------------------
TAG="${1:-sit}"                 # Use first argument, default to "sit"
IMAGE="ghcr.io/podaac/podaac-airflow:$TAG"
EXPECTED_VERSION="2.10.5"

# ----------------------------
# Pull Docker image
# ----------------------------
echo "🔹 Pulling Docker image '$IMAGE' (no local cache)..."
docker rmi "$IMAGE" >/dev/null 2>&1 || true
docker pull "$IMAGE"

# ----------------------------
# Verify image exists locally
# ----------------------------
echo "🔹 Verifying image exists locally..."
docker image inspect "$IMAGE" > /dev/null

# ----------------------------
# Test Airflow version
# ----------------------------
echo "🔹 Testing Airflow version..."
ACTUAL_VERSION=$(docker run --rm "$IMAGE" airflow version 2>/dev/null | tr -d '\r\n' | xargs)

if [[ "$ACTUAL_VERSION" == "$EXPECTED_VERSION" ]]; then
  echo "✅ PASS: Airflow version is $ACTUAL_VERSION"
else
  echo "❌ FAIL: Expected Airflow $EXPECTED_VERSION, got '${ACTUAL_VERSION:-none}'"
  exit 1
fi

# ----------------------------
# Test webserver output (without DB)
# ----------------------------
echo "🔹 Testing webserver output (DB not initialized)..."
WEB_OUTPUT=$(docker run --rm "$IMAGE" airflow webserver 2>&1 || true)

if echo "$WEB_OUTPUT" | grep -q "You need to initialize the database"; then
  echo "✅ PASS: Webserver output as expected (DB not initialized)"
else
  echo "❌ FAIL: Unexpected webserver output"
  exit 1
fi

echo "🎉 All tests passed for '$IMAGE'"
