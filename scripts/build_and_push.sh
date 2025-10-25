#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/build_and_push.sh <image-name> [tag]
# Example: ./scripts/build_and_push.sh kushagrasaxena77/demo-app

IMAGE_NAME=${1:?Image name required}
TAG=${2:-}

if [ -z "$TAG" ]; then
  SHORT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo local)
  TAG=${SHORT_SHA}-$(date +%s)
fi

IMAGE=${IMAGE_NAME}:${TAG}

echo "Building ${IMAGE}..."
docker build -t ${IMAGE} .

# Login: this script expects DOCKER_USER and DOCKER_PASS env vars.
if [ -z "${DOCKER_USER:-}" ] || [ -z "${DOCKER_PASS:-}" ]; then
  echo "DOCKER_USER and DOCKER_PASS environment variables required for push."
  echo "You can run: DOCKER_USER=you DOCKER_PASS=token ./scripts/build_and_push.sh ${IMAGE_NAME} ${TAG}"
  exit 1
fi

echo "Logging into Docker registry..."
echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin

echo "Pushing ${IMAGE}..."
docker push ${IMAGE}

echo "Logout"
docker logout || true

echo "Done: ${IMAGE}"
