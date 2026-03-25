#!/bin/bash
# Install Docker
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo usermod -aG docker $USER

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start Minikube
minikube start --driver=docker

# Apply Kubernetes Files
minikube kubectl -- apply -f ../k8s/postgres_db.yaml
minikube kubectl -- apply -f ../k8s/main.yaml
