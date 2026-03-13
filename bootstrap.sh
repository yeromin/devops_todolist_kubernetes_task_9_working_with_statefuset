#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "Applying MySQL StatefulSet resources..."
kubectl apply -f .infrastructure/statefulSet.yml

echo "Waiting for MySQL StatefulSet to be ready..."
kubectl rollout status statefulset/mysql -n mysql --timeout=300s

echo "Applying todoapp namespace..."
kubectl apply -f .infrastructure/namespace.yml

echo "Applying todoapp storage resources..."
kubectl apply -f .infrastructure/pv.yml
kubectl apply -f .infrastructure/pvc.yml

echo "Applying todoapp config and secrets..."
kubectl apply -f .infrastructure/configMap.yml
kubectl apply -f .infrastructure/secret.yml

echo "Applying todoapp workload and services..."
kubectl apply -f .infrastructure/deployment.yml
kubectl apply -f .infrastructure/clusterIp.yml
kubectl apply -f .infrastructure/nodeport.yml
kubectl apply -f .infrastructure/hpa.yml

echo "Waiting for todoapp deployment rollout..."
kubectl rollout status deployment/todoapp -n todoapp --timeout=300s

echo "Deployment finished."
kubectl get pods -n mysql
kubectl get pods -n todoapp
kubectl get svc -n mysql
kubectl get svc -n todoapp
