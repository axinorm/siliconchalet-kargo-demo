#!/bin/bash

set -e
set -o pipefail

CERT_MANAGER_CHART_VERSION=1.16.1
ARGO_CD_CHART_VERSION=7.7.0
KARGO_CHART_VERSION=1.0.3

echo
echo "###########################"
echo "# [KARGO] Install cluster #"
echo "###########################"
echo

# Cert-manager
echo
echo "==========================="
echo "[INFO] Install cert-manager"
echo "==========================="
echo

helm upgrade --install cert-manager cert-manager \
  --repo https://charts.jetstack.io \
  --version ${CERT_MANAGER_CHART_VERSION} \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true \
  --wait

# Argo CD
echo
echo "======================"
echo "[INFO] Install argo-cd"
echo "======================"
echo

helm upgrade --install argocd argo-cd \
  --repo https://argoproj.github.io/argo-helm \
  --version ${ARGO_CD_CHART_VERSION} \
  --namespace argocd \
  --create-namespace \
  --set dex.enabled=false \
  --set notifications.enabled=false \
  --set server.service.type=NodePort \
  --set server.service.nodePortHttp=31443 \
  --wait

# Kargo
echo
echo "===================="
echo "[INFO] Install kargo"
echo "===================="
echo

helm upgrade --install kargo \
  oci://ghcr.io/akuity/kargo-charts/kargo \
  --version ${KARGO_CHART_VERSION} \
  --namespace kargo \
  --create-namespace \
  --set api.service.type=NodePort \
  --set api.service.nodePort=31444 \
  --set api.adminAccount.passwordHash='$2a$10$Zrhhie4vLz5ygtVSaif6o.qN36jgs6vjtMBdM6yrU1FOeiAAMMxOm' \
  --set api.adminAccount.tokenSigningKey=iwishtowashmyirishwristwatch \
  --wait
