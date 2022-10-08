#!/bin/bash

kubectl create ns monitoring-demo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus-demo prometheus-community/prometheus -n monitoring-demo -f monitoring/falcosidekickExtraScrapeConfigs.yaml
helm repo add grafana https://grafana.github.io/grafana/charts
helm repo update
helm install grafana-demo grafana/grafana -n monitoring-demo
helm repo add loki https://grafana.github.io/loki/charts
helm repo update
helm install loki-demo grafana/loki-stack -n monitoring-demo

kubectl create namespace argo-events
kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install.yaml
kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install-validating-webhook.yaml
kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml

kubectl create namespace argo
kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo-workflows/stable/manifests/install.yaml
kubectl patch -n argo cm workflow-controller-configmap -p '{"data": {"containerRuntimeExecutor": "pns"}}'

kubectl -n argo-events apply -f argo/eventSource.yaml
kubectl apply -n argo-events -f argo/sensor-requirments.yaml
kubectl apply -n argo -f argo/workflowTemplate.yaml

kubectl create ns falco
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm install falco falcosecurity/falco \
  --version 1.16.4 \
  --namespace falco \
  -f falco/valuesFalco.yaml

kubectl create ns cloudconf2022demo
