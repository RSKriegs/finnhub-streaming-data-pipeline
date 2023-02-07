#!/bin/sh

helm repo add incubator https://charts.helm.sh/incubator --force-update

kubectl create namespace spark-operator

helm install incubator/sparkoperator \
--namespace spark-operator \
--set sparkJobNamespace=default \
--set operatorVersion=latest \
--set enableWebhook=true \
--set enableBatchScheduler=true \
--generate-name

kubectl apply -f spark-rbac.yaml
