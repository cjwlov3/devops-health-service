# DevOps Health Service

A Python HTTP service that returns `{"status": "ok"}` at `/health`.
GitHub Actions runs the automated test and builds the Docker image on every push.
The service deploys to a local Kubernetes cluster using kind.

## Test and build

Run from the repository root:

```bash
python3 -m unittest -v
sudo docker build -t devops-health-service:local .
```

## Deploy locally

With Docker, kind, and kubectl installed, run these commands from the repository
root. If `devops-lab` already exists, skip the cluster creation command.

```bash
sudo -H kind create cluster --name devops-lab
sudo -H kind load docker-image devops-health-service:local --name devops-lab
sudo -H kubectl --context kind-devops-lab apply -f deployment.yaml
sudo -H kubectl --context kind-devops-lab rollout status deployment/health-service --timeout=90s
sudo -H kubectl --context kind-devops-lab get pods -l app=health-service
```

A successful rollout shows a pod with `1/1` under READY and `Running` under STATUS.
The readiness probe checks `/health` on port `8080`.

## Rollback drill

I changed the live readiness probe from `/health` to `/wrong-health`.
The rollout timed out. Using `kubectl describe pods`, I saw that the new
pod was running but showed `Ready: False`, while the original pod stayed
ready. I restored the previous revision with `kubectl rollout undo` and
verified that Kubernetes reported a successful rollout.
