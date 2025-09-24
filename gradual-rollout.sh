#!/bin/bash

# Configuration
BLUE_DEPLOYMENT="app-blue"
GREEN_DEPLOYMENT="app-green"
INITIAL_REPLICAS=5
STEP_PERCENTAGE=20
SLEEP_DURATION=30  # seconds between steps

# Calculate step size
STEP_SIZE=$((INITIAL_REPLICAS * STEP_PERCENTAGE / 100))

echo "Starting gradual rollout..."
echo "Step size: $STEP_SIZE replicas"

# Initial setup - ensure Green deployment starts with 0 replicas
kubectl scale deployment $GREEN_DEPLOYMENT --replicas=0

# Gradually increase Green while decreasing Blue
for i in $(seq 1 $((100/STEP_PERCENTAGE))); do
    BLUE_REPLICAS=$((INITIAL_REPLICAS - (i * STEP_SIZE)))
    GREEN_REPLICAS=$((i * STEP_SIZE))
    
    echo "Step $i:"
    echo "Scaling $BLUE_DEPLOYMENT to $BLUE_REPLICAS replicas"
    echo "Scaling $GREEN_DEPLOYMENT to $GREEN_REPLICAS replicas"
    
    kubectl scale deployment $BLUE_DEPLOYMENT --replicas=$BLUE_REPLICAS
    kubectl scale deployment $GREEN_DEPLOYMENT --replicas=$GREEN_REPLICAS
    
    echo "Waiting $SLEEP_DURATION seconds before next step..."
    sleep $SLEEP_DURATION
    
    # Show current pod distribution
    echo "Current pod distribution:"
    kubectl get pods -l app=demo -L version
done

echo "Rollout complete! Green deployment is now handling 100% of traffic"