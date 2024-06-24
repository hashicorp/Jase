#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


kubectl create namespace base
#kubectl apply -f resources/k8s-yamls/example.yaml -n base

kubectl create namespace team1
#kubectl apply -f resources/k8s-yamls/example.yaml -n team1

kubectl apply -f resources/hashicups/ -n team1

kubectl create namespace team2
#kubectl apply -f resources/k8s-yamls/example.yaml -n team2

kubectl create namespace team3
#kubectl apply -f resources/k8s-yamls/example.yaml -n team3
