#!/bin/bash

# Configuration
BLUE_DEPLOYMENT="app-blue"
GREEN_DEPLOYMENT="app-green"
INITIAL_REPLICAS=5
STEP_PERCENTAGE=20
SLEEP_DURATION=30  # seconds between steps

# Calculate step size
STEP_SIZE=$((INITIAL_REPLICAS * STEP_PERCENTAGE / 100))

echo "Starting rollback to Blue deployment..."
echo "Step size: $STEP_SIZE replicas"

# Get current replica count for both deployments
CURRENT_GREEN_REPLICAS=$(kubectl get deployment $GREEN_DEPLOYMENT -o=jsonpath='{.spec.replicas}')
CURRENT_BLUE_REPLICAS=$(kubectl get deployment $BLUE_DEPLOYMENT -o=jsonpath='{.spec.replicas}')

echo "Current state:"
echo "$BLUE_DEPLOYMENT: $CURRENT_BLUE_REPLICAS replicas"
echo "$GREEN_DEPLOYMENT: $CURRENT_GREEN_REPLICAS replicas"

# Calculate number of steps needed
STEPS=$((CURRENT_GREEN_REPLICAS / STEP_SIZE))
if [ $((CURRENT_GREEN_REPLICAS % STEP_SIZE)) -ne 0 ]; then
    STEPS=$((STEPS + 1))
fi

# Gradually decrease Green while increasing Blue
for i in $(seq 1 $STEPS); do
    GREEN_REPLICAS=$((CURRENT_GREEN_REPLICAS - (i * STEP_SIZE)))
    BLUE_REPLICAS=$((CURRENT_BLUE_REPLICAS + (i * STEP_SIZE)))
    
    # Ensure we don't go below 0 for Green
    if [ $GREEN_REPLICAS -lt 0 ]; then
        GREEN_REPLICAS=0
    fi
    
    # Ensure we don't exceed INITIAL_REPLICAS for Blue
    if [ $BLUE_REPLICAS -gt $INITIAL_REPLICAS ]; then
        BLUE_REPLICAS=$INITIAL_REPLICAS
    fi
    
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

echo "Rollback complete! Blue deployment is now handling 100% of traffic"
