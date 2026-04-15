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

echo "🔹 Initializing DB and starting Airflow API server on http://localhost:8080/docs..."
docker run --rm -p 8080:8080 "$IMAGE" bash -c "airflow db migrate && airflow api-server --help"
