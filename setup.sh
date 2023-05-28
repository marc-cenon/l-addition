#!/bin/bash

#shell script to setup minikube, terraform, kubectl, helm and docker on a new ubuntu vm

# installing curl if not already present
echo "installing curl"
sudo apt install -y curl

# install kubectl
echo "install kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# install helm
echo "installing helm"
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# install terraform
echo "install terraform"
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update

sudo apt-get install terraform

## download minikube
echo "download minikube"
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

## install minikube
echo "install minikube"
sudo install minikube-linux-amd64 /usr/local/bin/minikube

## install docker
echo "installing docker"
curl -fsSL https://get.docker.com -o install-docker.sh
sudo sh ./install-docker.sh
sudo usermod -aG docker $USER && newgrp docker
