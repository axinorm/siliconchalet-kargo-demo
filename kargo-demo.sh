#!/bin/bash

set -e
set -o pipefail

killall -q kubectl || true
clear

echo
echo "################"
echo "# [KARGO] Demo #"
echo "################"
echo

echo "========="
echo " Argo CD "
echo "========="
echo

# Argo CD - Connect to UI
echo
echo "Argo CD UI URL : https://localhost:9000"

ARGO_CD_UI_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d | xargs)
echo "Argo CD UI password : ${ARGO_CD_UI_PASSWORD}"

read -rs

# Argo CD - ApplicationSet

echo
echo "[INFO] Create Argo CD ApplicationSet"
echo

cat <<EOF | kubectl -n argocd apply -f -
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: siliconchalet-repo
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: ${REPOSITORY_URL}
  username: ${GITHUB_USERNAME}
  password: ${GITHUB_PAT}
EOF

(set -x; kubectl -n argocd apply -f ./argocd/configurations/siliconchalet-appproject.yaml)
(set -x; envsubst < ./argocd/configurations/siliconchalet-apps.yaml | kubectl -n argocd apply -f -)

read -rs

# Kargo
echo
echo "======="
echo " Kargo "
echo "======="
echo

echo "Kargo UI URL : https://localhost:9100"

sleep 1

kargo login https://localhost:9100 \
  --admin \
  --password admin \
  --insecure-skip-tls-verify

read -rs

# Kargo configuration
echo
echo "[INFO] Setup Kargo"
echo

(set -x; kargo apply -f ./kargo/configurations/siliconchalet-project.yaml)

cat <<EOF | kargo apply -f -
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: siliconchalet-repo
  namespace: siliconchalet
  labels:
    kargo.akuity.io/cred-type: git
stringData:
  repoURL: ${REPOSITORY_URL}
  username: ${GITHUB_USERNAME}
  password: ${GITHUB_PAT}
EOF

read -rs

# Kargo Stages
echo
echo "[INFO] Create Stages"
echo
(set -x; kargo apply -f ./kargo/configurations/siliconchalet-warehouse.yaml)
(set -x; envsubst < ./kargo/configurations/siliconchalet-development-stage.yaml | kargo apply -f -)
(set -x; envsubst < ./kargo/configurations/siliconchalet-testing-stage.yaml | kargo apply -f -)
(set -x; envsubst < ./kargo/configurations/siliconchalet-production-stage.yaml | kargo apply -f -)

read -rs

# Development environment
nohup kubectl -n siliconchalet-app-development port-forward services/siliconchalet-app --address localhost,127.0.0.1 9210:80 >/dev/null 2>&1 &
DEV_ENV_PORT_FORWARD_PID=$!
echo
echo
echo "[INFO] Development environment : http://localhost:9210"

echo 
echo "# Stages"
(set -x; kargo get stages --project siliconchalet)
echo
echo "# Promotions"
(set -x; kargo get promotions --project siliconchalet)
echo

read -rs

# Testing environment
nohup kubectl -n siliconchalet-app-testing port-forward services/siliconchalet-app --address localhost,127.0.0.1 9220:80 >/dev/null 2>&1 &
TEST_ENV_PORT_FORWARD_PID=$!
echo
echo
echo "[INFO] Testing environment : http://localhost:9220"

echo 
echo "# Stages"
(set -x; kargo get stages --project siliconchalet)
echo
echo "# Promotions"
(set -x; kargo get promotions --project siliconchalet)
echo

read -rs

# Production environment
nohup kubectl -n siliconchalet-app-production port-forward services/siliconchalet-app --address localhost,127.0.0.1 9230:80 >/dev/null 2>&1 &
PROD_ENV_PORT_FORWARD_PID=$!
echo
echo
echo "[INFO] Production environment : http://localhost:9230"

echo 
echo "# Stages"
(set -x; kargo get stages --project siliconchalet)
echo
echo "# Promotions"
(set -x; kargo get promotions --project siliconchalet)
echo

read -rs

kill ${DEV_ENV_PORT_FORWARD_PID} >/dev/null 2>&1
kill ${TEST_ENV_PORT_FORWARD_PID} >/dev/null 2>&1
kill ${PROD_ENV_PORT_FORWARD_PID} >/dev/null 2>&1
