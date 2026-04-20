#!/usr/bin/env bash
set -euo pipefail

# ----------------------------
# Config
# ----------------------------
TAG="${1:-sit}"                 # Use first argument, default to "sit"
IMAGE="ghcr.io/podaac/podaac-airflow:$TAG"
EXPECTED_VERSION="3.1.8"

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
set +e
set +o pipefail
VERSION_RAW="$(docker run --rm "$IMAGE" airflow version 2>&1)"
DOCKER_RUN_STATUS=$?
set -o pipefail
set -e

# Normalize CRLF and extract an x.y.z version from any output (handles warnings).
VERSION_RAW="${VERSION_RAW//$'\r'/}"
ACTUAL_VERSION=""
if [[ "$VERSION_RAW" =~ ([0-9]+\.[0-9]+\.[0-9]+) ]]; then
  ACTUAL_VERSION="${BASH_REMATCH[1]}"
fi

echo "   Airflow reported: ${ACTUAL_VERSION:-<unparsed>}"
echo "   Expected: $EXPECTED_VERSION"

if [[ $DOCKER_RUN_STATUS -ne 0 ]]; then
  echo "❌ FAIL: 'docker run ... airflow version' exited with $DOCKER_RUN_STATUS"
  echo "---- docker output ----"
  echo "$VERSION_RAW"
  echo "-----------------------"
  exit 1
fi

if [[ "$ACTUAL_VERSION" == "$EXPECTED_VERSION" ]]; then
  echo "✅ PASS: Airflow version is $ACTUAL_VERSION"
else
  echo "❌ FAIL: Expected Airflow $EXPECTED_VERSION, got '${ACTUAL_VERSION:-none}'"
  exit 1
fi

# ----------------------------
# Test webserver output (without DB)
# ----------------------------
echo "🔹 Testing webserver command..."

# Airflow 3.x output/exit behavior can differ depending on config and DB state.
# The most stable smoke-test is verifying the CLI wiring for the webserver command.
if ! docker run --rm "$IMAGE" airflow api-server --help >/dev/null 2>&1; then
  echo "❌ FAIL: 'airflow api-server --help' failed"
  docker run --rm -p 8080:8080 "$IMAGE" bash -c "airflow db migrate && airflow api-server --help"
  exit 1
fi

echo "✅ PASS: Webserver command is available"

echo "🎉 All tests passed for '$IMAGE'"
