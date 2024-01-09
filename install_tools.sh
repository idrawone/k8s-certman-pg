#!/bin/bash

# Specify tool versions
MINIKUBE_VERSION="v1.32.0"
KUBECTL_VERSION="v1.29.0"
HELM_VERSION="v3.13.1"

# Create bin folder if it doesn't exist
mkdir -p bin

# Check and install Minikube
if ! [ -x "$(command -v bin/minikube)" ] || [ "$(bin/minikube version --short)" != "$MINIKUBE_VERSION" ]; then
    echo "> Install minikube version $MINIKUBE_VERSION"
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    install minikube-linux-amd64 bin/minikube
    chmod +x bin/minikube
    rm minikube-linux-amd64
fi

if ! [ -x "$(command -v bin/kubectl)" ] || [ "$(bin/kubectl version | awk '/Client/{print $3}')" != "$KUBECTL_VERSION" ]; then
    echo "> Install kubectl version $KUBECTL_VERSION"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install kubectl bin/kubectl
    chmod +x bin/kubectl
    rm kubectl
fi

# Check and install Helm
if ! [ -x "$(command -v bin/helm)" ] || [ "$(bin/helm version --short | grep -o 'v[0-9]\.[0-9]\+\.[0-9]\+')" != "$HELM_VERSION" ]; then
    echo "> Install helm version $HELM_VERSION"
    curl -fsSL -o bin/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod +x bin/get_helm.sh
    HELM_INSTALL_DIR=bin bin/get_helm.sh --no-sudo
fi


echo "Setup complete. You need to run below command in your shell to use specified versions"
echo "export PATH=$(pwd)/bin:\$PATH" 
