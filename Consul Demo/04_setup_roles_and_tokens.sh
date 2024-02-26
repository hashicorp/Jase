#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


export CONSUL_HTTP_TOKEN=`kubectl get secrets/consul-bootstrap-acl-token --template='{{.data.token | base64decode }}' -n consul`

consul intention create '*/*' '*/*'

consul intention create 'k8s-team1/*' 'k8s-base/*'
consul intention create 'k8s-team2/*' 'k8s-base/*'
consul intention create 'k8s-team3/*' 'k8s-base/*'

consul intention create 'k8s-team1/*' 'k8s-team1/*'
consul intention create 'k8s-team2/*' 'k8s-team2/*'
consul intention create 'k8s-team3/*' 'k8s-team3/*'


consul acl role create -name "team1" -description "team1 role" -policy-name "team1"
consul acl role create -name "team2" -description "team2 role" -policy-name "team2"
consul acl role create -name "team3" -description "team3 role" -policy-name "team3"

echo "=========================================================================="
echo "Create the Tokens for the different teams:"
echo "=========================================================================="
consul acl token create -description "Team1 Admin" -role-name team1
echo "=========================================================================="
consul acl token create -description "Team2 Admin" -role-name team2
echo "=========================================================================="
consul acl token create -description "Team3 Admin" -role-name team3
echo "=========================================================================="

echo "Make sure to write down the above secretIDs for each Team Admin to test the access via UI!"
echo "http://localhost:8080/ui/"
echo ""
echo "You can also use the bootstrap token for 'superadmin' access."
echo "As a reminder, your bootstrap token is: $CONSUL_HTTP_TOKEN"