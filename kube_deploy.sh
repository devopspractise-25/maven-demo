#!/bin/bash

# --- Configuration Variables (REPLACE THESE!) ---
MINIKUBE_SERVER_IP="10.128.0.7" # e.g., 192.168.1.100
MINIKUBE_SERVER_USER="devopspractise25" # e.g., docker or devopspractise25
REMOTE_DEPLOY_DIR="/tmp/k8s-deploy-$(date +%s)" # A temporary directory on the remote server

DEPLOYMENT_YAML="my-app-deployment.yaml"
SERVICE_YAML="my-app-service.yaml"

# --- Navigate to the directory where your YAMLs are in Jenkins workspace ---
# If your YAMLs are at the root of the Git repo, you might not need this 'cd'
# Example: cd kubernetes-manifests/ # If YAMLs are in a subfolder of your repo
echo "Current directory on Jenkins agent: $(pwd)"
ls -l

echo "--- Creating temporary deployment directory on remote Minikube server ---"
ssh "${MINIKUBE_SERVER_USER}@${MINIKUBE_SERVER_IP}" "mkdir -p ${REMOTE_DEPLOY_DIR}" || { echo "Failed to create remote dir"; exit 1; }

echo "--- Copying Kubernetes YAMLs to remote Minikube server ---"
scp "${DEPLOYMENT_YAML}" "${MINIKUBE_SERVER_USER}@${MINIKUBE_SERVER_IP}:${REMOTE_DEPLOY_DIR}/" || { echo "Failed to copy deployment YAML"; exit 1; }
scp "${SERVICE_YAML}" "${MINIKUBE_SERVER_USER}@${MINIKUBE_SERVER_IP}:${REMOTE_DEPLOY_DIR}/" || { echo "Failed to copy service YAML"; exit 1; }

echo "--- Applying Kubernetes manifests on remote Minikube cluster ---"
# The 'ssh' command executes commands directly on the remote server
ssh "${MINIKUBE_SERVER_USER}@${MINIKUBE_SERVER_IP}" " \
  cd ${REMOTE_DEPLOY_DIR} && \
  echo 'Applying Deployment...' && \
  kubectl apply -f ${DEPLOYMENT_YAML} && \
  echo 'Applying Service...' && \
  kubectl apply -f ${SERVICE_YAML} && \
  echo 'Waiting for Deployment to be ready (optional, max 5m)...' && \
  kubectl rollout status deployment/my-java-app-deployment --timeout=5m && \
  echo '--- Deployment status ---' && \
  kubectl get deployments && \
  echo '--- Pod status ---' && \
  kubectl get pods -l app=my-java-app && \
  echo '--- Service status ---' && \
  kubectl get services my-java-app-service && \
  echo '--- Getting Minikube IP and Service URL for external access ---' && \
  MINIKUBE_IP=\$(minikube ip) && \
  NODE_PORT=\$(kubectl get service my-java-app-service -o jsonpath='{.spec.ports[0].nodePort}') && \
  echo 'Application should be accessible at: http://${MINIKUBE_IP}:${NODE_PORT}' && \
  minikube service my-java-app-service --url # Use --dry-run to prevent opening browser
" || { echo "Kubectl commands on remote server failed"; exit 1; }

echo "--- Cleaning up temporary deployment directory on remote Minikube server ---"
ssh "${MINIKUBE_SERVER_USER}@${MINIKUBE_SERVER_IP}" "rm -rf ${REMOTE_DEPLOY_DIR}" || { echo "Failed to clean up remote dir"; exit 1; }

echo "--- Deployment job completed ---"