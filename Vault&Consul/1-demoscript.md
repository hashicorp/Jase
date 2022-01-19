# Vaultbackend for Consul K8s 
1. run
```
helm install  -n vault --create-namespace -f vault-values.yaml --debug --wait vault hashicorp/vault
```
2.  Export the vault server address
```
export VAULT_ADDR=http://$(kubectl get svc -n vault vault-ui -o json | jq -r '.status.loadBalancer.ingress[]| .hostname'):$(kubectl get svc -n vault vault-ui -o json | jq -r '.spec.ports[]| .port')
echo $VAULT_ADDR
```
3.  Browse to the vault_addr and unseal vault. make sure to download the key file
4.  Run the following line of code to set the vault token
`export VAULT_TOKEN=<token> #put token from key file here`
5. Run the following commands in a shell. Reason for running this outside of the vault pod is the availability of the consul cli for keygen
```
vault secrets enable -path=consul kv-v2
vault kv put consul/secret/gossip gossip="$(consul keygen)"
```
6. Open a shell into one of the vault server pods:
`kubectl exec --stdin=true --tty=true vault-0 -n vault -- /bin/sh #shell into the pod`
8. Run the following commands:

```
export VAULT_TOKEN=<> #use token from above

vault auth enable kubernetes

vault write auth/kubernetes/config \
  token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
  kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt 

vault secrets enable pki

vault secrets enable -path connect-root pki

vault secrets tune -max-lease-ttl=87600h pki

vault write -field=certificate pki/root/generate/internal \
        common_name="dc1.consul" \
        ttl=87600h

vault policy write gossip-policy - <<EOF
path "consul/data/secret/gossip" {
  capabilities = ["read"]
}
EOF

vault policy write consul-server - <<EOF
path "kv/data/consul-server"
{
  capabilities = ["read"]
}
path "pki/issue/consul-server"
{
  capabilities = ["read","update"]
}
path "pki/cert/ca"
{
  capabilities = ["read"]
}
EOF


vault policy write ca-policy - <<EOF
path "pki/cert/ca" {
  capabilities = ["read"]
}
EOF

vault policy write connect - <<EOF
path "connect-root/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
path "connect-intermediate*"
{
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "sys/mounts"
{
  capabilities = ["create","update","read","sudo"]
}
path "sys/mounts/*"
{
  capabilities = ["create","update","read","sudo"]
}
path "auth/token/lookup" {
  capabilities = ["create","update"]
}
EOF


vault write pki/roles/consul-server \
  allowed_domains="dc1.consul,consul-server,consul-server.consul,consul-server.consul.svc" \
  allow_subdomains=true \
  allow_bare_domains=true \
  allow_localhost=true \
  generate_lease=true \
  max_ttl="720h"

vault write auth/kubernetes/role/consul-server \
        bound_service_account_names=consul-server \
        bound_service_account_namespaces=consul \
        policies="gossip-policy,consul-server,connect" \
        ttl=24h

vault write auth/kubernetes/role/consul-client \
        bound_service_account_names=consul-client \
        bound_service_account_namespaces=consul \
        policies="gossip-policy,ca-policy" \
        ttl=24h

vault write auth/kubernetes/role/consul-ca \
    bound_service_account_names="*" \
    bound_service_account_namespaces=consul \
    policies=ca-policy\
    ttl=1h
```
7. (the bellow assumes you have the enterprise license pre created as a secret)
run 
```
helm install -n consul -f consul-values.yaml --debug --wait consul hashicorp/consul
```

vault-values.yaml

server:
  standalone:
    enabled: true
    config: |
      ui = true
      listener "tcp" {
        tls_disable = 1
        address = "[::]:8200"
        cluster_address = "[::]:8201"
      }
      storage "file" {
        path = "/vault/data"
      }
  service:
    enabled: true
  dataStorage:
    enabled: true
    size: 10Gi
    storageClass: null
    accessMode: ReadWriteOnce
injector:
  enabled: true
  logLevel: "debug" 
ui:
  enabled: true
  serviceType: LoadBalancer


consul-values.yaml

global:
  datacenter: "dc1"
  name: consul
  domain: consul
  image: hashicorp/consul-enterprise:1.11.1-ent
  secretsBackend:
    vault:
      enabled: true
      consulServerRole: consul-server
      consulClientRole: consul-client
      consulCARole: consul-ca
      connectCA:
        address: http://vault.vault:8200
        rootPKIPath: connect-root/
        intermediatePKIPath: connect-intermediate-dc1/
  enterpriseLicense:
    secretName: consul-ent-license
    secretKey: key
  adminPartitions:
    enabled: true
  tls:
    enabled: true
    enableAutoEncrypt: true
    caCert:
      secretName: "pki/cert/ca"
    #httpsOnly: false
  federation:
    enabled: false
    createFederationSecret: false
  acls:
    manageSystemACLs: true
    #createReplicationToken: true
  gossipEncryption:
    #autoGenerate: true
    secretName: consul/data/secret/gossip
    secretKey: gossip
  enableConsulNamespaces: true
  # metrics:
  #   enabled: true
  #   enableAgentMetrics: true
  #   enableGatewayMetrics: true
server:
  replicas: 1
  exposeGossipAndRPCPorts: true
  serverCert:
    secretName: "pki/issue/consul-server"
connectInject:
  replicas: 1
  enabled: true
  transparentProxy:
    defaultEnabled: true
  # envoyExtraArgs: "--log-level debug"
  consulNamespaces:
    mirroringK8S: true
  # metrics:
  #   defaultEnableMerging: true
  #   defaultPrometheusScrapePort: 20200
  #   defaultPrometheusScrapePath: "/metrics"
prometheus:
  enabled: true
controller:
  enabled: true

#not supported with the current vault backend
meshGateway:
  enabled: false
  replicas: 1
ingressGateways:
  replicas: 1
  enabled: enable
  gateways:
    - name: ingress-gateway
      service:
        type: LoadBalancer
terminatingGateways:
  replicas: 1
  enabled: true
  gateways:
  - name: terminating-gateway
ui:
  service:
    type: LoadBalancer
  metrics:
    provider: prometheus
    baseURL: http://prometheus-server
syncCatalog:
  enabled: true
  consulNamespaces:
    mirroringK8S: true
  k8sDenyNamespaces: ["kube-system", "kube-public", "consul"]
