#!/usr/bin/env bash
set -euo pipefail

# Local build image name
IMAGE="podaac-airflow-build-test"

echo "🔹 Building a fresh Docker image '$IMAGE' (no cache)..."
docker build --no-cache -t "$IMAGE" .

echo "🔹 Verifying image exists..."
docker image inspect "$IMAGE" > /dev/null

echo "🔹 Testing airflow version..."
docker run --rm "$IMAGE" airflow version

echo "🔹 Starting airflow webserver on localhost:8080 (press Ctrl+C to stop)..."
docker run --rm -p 8080:8080 "$IMAGE" airflow webserver
