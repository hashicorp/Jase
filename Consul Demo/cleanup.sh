#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


helm delete consul --namespace consul
kubectl delete namespace consul

kubectl delete namespace base
kubectl delete namespace team1
kubectl delete namespace team2
kubectl delete namespace team3

rm -rf hashicups