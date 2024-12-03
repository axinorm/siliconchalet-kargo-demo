#!/bin/bash

set -e
set -o pipefail

echo
echo "[INFO] Delete Argo CD configurations"
echo

(set -x; kubectl -n argocd delete -f ./argocd/configurations/siliconchalet-apps.yaml --ignore-not-found --force --grace-period 0)
sleep 5
(set -x; kubectl -n argocd delete -f ./argocd/configurations/siliconchalet-appproject.yaml --ignore-not-found --force --grace-period 0)
(set -x; kubectl -n argocd delete secret siliconchalet-repo --ignore-not-found --force --grace-period 0)

(set -x; kubectl delete ns siliconchalet-app-development --ignore-not-found --force --grace-period 0)
(set -x; kubectl delete ns siliconchalet-app-testing --ignore-not-found --force --grace-period 0)
(set -x; kubectl delete ns siliconchalet-app-production --ignore-not-found --force --grace-period 0)

echo
echo "[INFO] Delete Kargo project"
echo

(set -x; kubectl delete projects.kargo.akuity.io siliconchalet --ignore-not-found --force --grace-period 0)
(set -x; kubectl -n siliconchalet delete secret siliconchalet-repo --ignore-not-found --force --grace-period 0)
echo
echo "[INFO] Delete Kargo Stages"
echo

(set -x; kubectl delete -f ./kargo/configurations/siliconchalet-production-stage.yaml --ignore-not-found --force --grace-period 0)
(set -x; kubectl delete -f ./kargo/configurations/siliconchalet-testing-stage.yaml --ignore-not-found --force --grace-period 0)
(set -x; kubectl delete -f ./kargo/configurations/siliconchalet-development-stage.yaml --ignore-not-found --force --grace-period 0)
(set -x; kubectl delete -f ./kargo/configurations/siliconchalet-warehouse.yaml --ignore-not-found --force --grace-period 0)

killall -q kubectl || true
