#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


kubectl create namespace consul
secret=$(cat resources/consul.hclic)
kubectl create secret generic consul-ent-license --from-literal="key=${secret}" --namespace consul

helm install -f resources/config.yaml consul hashicorp/consul --namespace consul

helm list --namespace consul