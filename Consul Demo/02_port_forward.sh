#!/bin/bash

echo "please open two separate CLIs and use the following commands for port forwarding in each of the CLIs:"
echo "kubectl --namespace consul port-forward service/consul-ui 8080:80 --address 0.0.0.0 &"
echo "kubectl --namespace consul port-forward consul-server-0 8500:8500 &"
