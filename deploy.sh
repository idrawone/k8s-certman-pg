#!/bin/bash

# Check if minikube, kubectl, and helm are in the bin folder
if [ -x "$(command -v bin/minikube)" ] && [ -x "$(command -v bin/kubectl)" ] && [ -x "$(command -v bin/helm)" ]; then
    echo "> Minikube, kubectl, and Helm found in bin folder."
else
    echo "> Minikube, kubectl, or Helm not found in bin folder. Please run the installation script first."
    exit 1
fi

# Delete existing Minikube cluster
bin/minikube delete

# Start Minikube cluster
bin/minikube start

# Add jetstack repo
bin/helm repo add jetstack https://charts.jetstack.io
bin/helm repo update

# Install cert-manager
bin/helm install cert-manager jetstack/cert-manager --version v1.13.0 --set installCRDs=true --namespace sandbox --create-namespace

# Apply Kubernetes resources
kubectl apply -f self-signed-issuer.yaml
kubectl apply -f postgres-deployment.yaml

