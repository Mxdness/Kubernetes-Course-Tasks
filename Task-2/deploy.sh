#!/usr/bin/env bash
set -euo pipefail

chmod -x mysql/initdb/01-setup.sh
docker build -t webapp-api:task2 ./webapp
docker build -t webapp-mysql:task2 ./mysql
minikube image load webapp-api:task2
minikube image load webapp-mysql:task2
minikube image ls | grep task2

minikube addons enable ingress

kubectl apply -f ingress-namespace.yaml
kubectl apply -f webapp-stack-namespace.yaml
kubectl apply -f mysql-secret.yaml
kubectl apply -f webapp-configmap.yaml
kubectl apply -f pv-pvc.yaml
kubectl apply -f mysql-deployment.yaml
kubectl apply -f mysql-service.yaml
kubectl rollout status deploy/mysql -n webapp-stack --timeout=180s
kubectl apply -f webapp-deployment.yaml
kubectl apply -f webapp-service.yaml
kubectl rollout status deploy/webapp-api -n webapp-stack --timeout=120s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/component=controller -n ingress-nginx --timeout=180s
kubectl apply -f ingress.yaml

echo "Now run in a second terminal:"
echo "  kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80"
echo "and open http://localhost:8080"
