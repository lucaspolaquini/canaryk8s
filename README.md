# Advanced Kubernetes Deployment Strategies Demo

This demo showcases advanced deployment strategies with automatic traffic shifting between versions.

## Prerequisites

- Kubernetes cluster
- kubectl configured
- bash shell

## Project Structure

```
advanced-k8s-demo/
├── manifests/
│   ├── deployment.yaml    # Blue/Green deployments
│   ├── service.yaml       # Load balancer service
│   └── configmaps.yaml    # Version-specific configs
└── scripts/
    └── gradual-rollout.sh # Automated rollout script
```

## Setup Instructions

1. Create the resources:

```bash
kubectl apply -f manifests/configmaps.yaml
kubectl apply -f manifests/deployment.yaml
kubectl apply -f manifests/service.yaml
```

2. Make the script executable:

```bash
chmod +x scripts/gradual-rollout.sh
```

## Running the Demo

1. Start with full Blue deployment:

```bash
kubectl scale deployment app-blue --replicas=10
kubectl scale deployment app-green --replicas=0
```

2. Run the gradual rollout:

```bash
./scripts/gradual-rollout.sh
```

The script will:
- Start with 3 Blue replicas and 0 Green replicas
- Every 30 seconds, shift 20% of traffic from Blue to Green
- Show pod distribution at each step
- Complete when Green handles 100% of traffic

## Monitoring the Rollout

Watch the pods during rollout:

```bash
kubectl get pods -l app=demo -L version -w
```

Check the service:

```bash
kubectl get svc app-service
```

## Cleanup

Delete all resources:

```bash
kubectl delete -f manifests/
```

## Customization

Edit these variables in `scripts/gradual-rollout.sh`:
- INITIAL_REPLICAS: Starting number of replicas
- STEP_PERCENTAGE: Percentage of traffic to shift each step
- SLEEP_DURATION: Seconds between steps