#!/bin/bash

export CONSUL_HTTP_TOKEN=`kubectl get secrets/consul-bootstrap-acl-token --template='{{.data.token | base64decode }}' -n consul`

consul acl policy create -name "team1" -description "Team 1 Policy" -rules @resources/policies/team1-policy.hcl
consul acl policy create -name "team2" -description "Team 2 Policy" -rules @resources/policies/team2-policy.hcl
consul acl policy create -name "team3" -description "Team 3 Policy" -rules @resources/policies/team3-policy.hcl

consul acl policy update -name "anonymous-token-policy" -description "Anonymous token Policy" -rules @resources/policies/anonymous-token-policy.hcl
#temporary disabled the changes consul acl policy update -name "cross-namespace-policy" -description "" -rules @resources/policies/cross-namespace-policy.hcl