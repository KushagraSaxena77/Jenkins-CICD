#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/deploy_local.sh <image-name> <tag>
# Example: ./scripts/deploy_local.sh kushagrasaxena77/demo-app abc123-1

IMAGE_NAME=${1:?Image name required}
IMAGE_TAG=${2:?Image tag required}

export IMAGE_NAME
export IMAGE_TAG

if ! command -v envsubst >/dev/null 2>&1; then
  echo "envsubst not found. Please install gettext (envsubst) or modify the script to use kubectl set image."
  exit 1
fi

echo "Substituting image in deployment.yaml and applying to cluster..."
envsubst < deployment.yaml | kubectl apply -f -

echo "Waiting for rollout..."
kubectl rollout status deployment/demo-app --timeout=120s

echo "Running cluster-side smoke test..."
kubectl run curl-test --rm --restart=Never --image=curlimages/curl --command -- curl -sS http://demo-app-svc:3000

echo "Deployment and smoke test completed."
