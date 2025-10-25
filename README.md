# demo-ci-cd

Minimal Node.js app + Docker + Kubernetes manifest + Jenkins pipeline example.

This repo contains a small express-like Node app, a Dockerfile, a Kubernetes manifest (`deployment.yaml`) and a declarative `Jenkinsfile` that builds, tags, pushes and deploys the app to Kubernetes.

## Goal
Build a CI/CD pipeline that:
- builds a Docker image
- tags it immutably (short-git-sha + build number)
- pushes to Docker Hub
- deploys to Kubernetes using a kubeconfig stored in Jenkins
- waits for rollout and runs a cluster-side smoke test

## Prerequisites (local & Jenkins agent)
- docker CLI (and access to a Docker daemon)
- kubectl
- envsubst (from gettext) OR pipeline can be switched to `kubectl set image` (see notes)
- git

On a Debian/Ubuntu agent you can install envsubst with:

```bash
sudo apt-get update && sudo apt-get install -y gettext-base
```

macOS (brew):

```bash
brew install gettext
brew link --force gettext
```

## Files of interest
- `app/index.js` — minimal app
- `package.json` — node scripts
- `Dockerfile` — builds the image
- `deployment.yaml` — k8s Deployment + Service (templated for envsubst)
- `Jenkinsfile` — declarative Jenkins pipeline
- `scripts/build_and_push.sh` — helper to build and push image locally
- `scripts/deploy_local.sh` — helper to deploy locally using envsubst

## Jenkins credentials required
Create these in Jenkins (Credentials -> System -> Global):

1. Username/Password
   - ID: `docker-hub-credentials-id`
   - Use a Docker Hub username and password/token

2. Secret file
   - ID: `kubeconfig`
   - Upload your kubeconfig file so the pipeline can use it

## Creating the Jenkins Pipeline
1. New Item -> Pipeline (or Multibranch Pipeline)
2. If Pipeline: choose "Pipeline script from SCM" -> Git -> repo URL: `https://github.com/<your-user>/<repo>.git` branch: `main`
2. If Pipeline: choose "Pipeline script from SCM" -> Git -> repo URL: `https://github.com/KushagraSaxena77/Jenkins-CICD.git` branch: `main`
3. Save and Build Now. The pipeline will use `Jenkinsfile` from repo root.

## Local commands (quick run)
Replace `<your-docker-user>` and `<your-tag>` appropriately. Example uses `kushagrasaxena77/demo-app` as `IMAGE_NAME`.

Build and tag locally (example):

```bash
SHORT_SHA=$(git rev-parse --short HEAD)
IMAGE_NAME=kushagrasaxena77/demo-app
IMAGE_TAG=${SHORT_SHA}-local1
# Build
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

# Push (login first)
docker login -u <your-docker-user>
docker push ${IMAGE_NAME}:${IMAGE_TAG}
```

Deploy locally (requires envsubst):

```bash
export IMAGE_NAME=kushagrasaxena77/demo-app
export IMAGE_TAG=${IMAGE_TAG}
envsubst < deployment.yaml | kubectl apply -f -
kubectl rollout status deployment/demo-app --timeout=120s
kubectl run curl-test --rm --restart=Never --image=curlimages/curl --command -- curl -sS http://demo-app-svc:3000
```

Or use the helper scripts in `scripts/` (make them executable first):

```bash
chmod +x scripts/*.sh
# Build and push (expects DOCKER_USER and DOCKER_PASS environment vars)
./scripts/build_and_push.sh kushagrasaxena77/demo-app
# Deploy
./scripts/deploy_local.sh kushagrasaxena77/demo-app ${SHORT_SHA}-local1
```

## Scripts
See `scripts/build_and_push.sh` and `scripts/deploy_local.sh` for exact commands the Jenkinsfile performs.

## Troubleshooting / Common issues
- docker daemon access: ensure Jenkins agent user can access Docker socket or use a dedicated build agent with Docker installed.
- kubeconfig permissions: ensure kubeconfig user can create/update deployments in the target namespace.
- envsubst not found: install `gettext` or switch to `kubectl set image` in Jenkinsfile.
- docker push unauthorized: ensure `docker-hub-credentials-id` is correct and has push rights.

## Next steps (optional)
- Add imagePullSecrets if using private registry for Kubernetes nodes.
- Add automated tests stage in Jenkins before image build.
- Use Helm for templated manifests or a GitOps tool (ArgoCD/Flux) for continuous delivery.

---

If you want, I can also commit a short `README-Jenkins.md` that shows screenshots / exact UI steps for Jenkins credential creation and pipeline creation.
