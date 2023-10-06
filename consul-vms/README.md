
Disclaimer: This setup is for POC purposes and not fit for production

Consul POC Guide
Prerequisites:

Install packer
Install consul client
Install kubectl
Install helm
Todo: add k8s and vm´s etc...

STEP BY STEP GUIDE on Installing Consul on VM´s with full zero trust and TLS.
This guide describes the following:

How top install 2 DC´s connected with wan federation.
TLS is enabled everywhere
Default Deny
Auto Encrypt
Setup of DC1
check the terraform.tfvars file and the variables main.tf file to make sure all variables are speficied and are correct according to your environment
Deploy the terraform script. This will deploy 4 VM´s: 2 for DC1 (1 DC server and 1 meshgateqay) and 2 for DC2. Only DC1 server is readyt to go.Follow the rest of this guide to install DC2.
The consul.hcl for DC1 will look something like this:
datacenter = "dc-1"
client_addr = "0.0.0.0"
data_dir = "/opt/consul"
encrypt = "ZZx3caCU2V9YmQNg+rXNvTbAIVP4Gc8gaUSTry7YoP4="
ca_file = "/etc/consul.d/consul-agent-ca.pem"
cert_file = "/etc/consul.d/dc1-server-consul-0.pem"
key_file = "/etc/consul.d/dc1-server-consul-0-key.pem"
verify_incoming = true
verify_outgoing = true
verify_server_hostname = true
server = true
bootstrap_expect = 1
ui = true
enable_central_service_config = true
auto_encrypt {
  allow_tls = true
}
acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
}
ports {
 grpc = 8502,
 https = 8501,
 http = -1
}
connect {
  enabled = true
  enable_mesh_gateway_wan_federation = true
} 
Bootstrap DC1 Server Run following command: Consul acl bootstrap
You will see an outbput that looks like this:

AccessorID:   4d123dff-f460-73c3-02c4-8dd64d136e01
SecretID:     86cddfb9-2760-d947-358d-a2811156bf31
Description:  Bootstrap Token (Global Management)
Local:        false
Create Time:  2018-10-22 11:27:04.479026 -0400 EDT
Policies:
   00000000-0000-0000-0000-000000000001 - global-management
Copy the secret ID and store this in the environment variables CONSUL_HTTP_TOKEN and CONSUL_MGMT_TOKEN by running folling command. Replace <bootstrap_token> by the token copied above

export CONSUL_HTTP_TOKEN="<bootstrap_token>"
export CONSUL_MGMT_TOKEN="<bootstrap_token>"
NOTE: The bootstrap token is like a 'root access' to your system and should only be used for initial bootstrap. Store it safely.

Before we can install and register any new node we need to create a node policy. Run the following command on the DC Server
sudo mkdir /opt/consul/policies
sudo tee /opt/policies/nodepolicy.hcl > /dev/null << EOF
agent_prefix "" {
  policy = "write"
}
node_prefix "" {
  policy = "write"
}
service_prefix "" {
  policy = "read"
}
session_prefix "" {
  policy = "read"
}
EOF

consul acl policy create \
  -token=${CONSUL_MGMT_TOKEN} \
  -name node-policy \
  -rules @/opt/policies/nodepolicy.hcl

consul acl token create \
  -token=${CONSUL_MGMT_TOKEN} \
  -description "node token” \
  -policy-name node-policy
Copy the secret id from the node token and run the following command consul acl set-agent-token agent "<node token>"

On the mesh gateway server run the following commands:
Replace with the ndoe token created above
Replace with the encryption key found on dc-1-server
sudo tee /etc/consul.d/consul.hcl > /dev/null << EOF
datacenter = "dc-1"
connect = {
  enabled = true
}
data_dir = "/opt/consul/data"
log_level = "DEBUG"
retry_join = ["provider=aws tag_key=consulserver tag_value=yes"]
ca_file = "/opt/consul/tls/consul-agent-ca.pem"
verify_incoming = false
verify_outgoing = true
verify_server_hostname = true
auto_encrypt = {
  tls = true
}
acl {
  enabled        = true
  default_policy = "deny"
  down_policy    = "extend-cache"
}
ports {
 grpc = 8502
}
encrypt = "<encryption key>"
EOF
In order for a mesh-gateway to register itself as a service it needs to have a token that allows it to do so.
sudo tee /opt/consul/policies/mgw.hcl > /dev/null << EOF
agent_prefix "" {
  policy = "read"
}
service_prefix "mesh-gateway" {
  policy = "write"
}
service_prefix "" {
  policy = "read"
}
node_prefix "" {
  policy = "write"
}
EOF

consul acl policy create \
  -token=${CONSUL_MGMT_TOKEN} \
  -name mgw-policy \
  -rules @/opt/consul/policies/mgw.hcl

consul acl token create \
  -token=${CONSUL_MGMT_TOKEN} \
  -description “mgw token" \
  -policy-name mgw-policy
You will need the secret id (token) from that last command in a later step.

We will now set a default config for the services in across all DC´s to use the local meshgateway as a default. There are other options here. TODO: Add link
Run the following command

sudo tee /opt/policies/default-policy.hcl > /dev/null << "EOF"
Kind = "proxy-defaults"
Name = "global"
MeshGateway {
   Mode = "local"
}
EOF

consul config write /opt/policies/default-policy.hcl
We are now ready to start the envoy.
We will first set some environment variables which will be used by the systemd service.

Run the following command: Change the by the internal IP of the server for DC1

sudo tee /etc/consul.d/envoy.env > /dev/null << "EOF"
CONSUL_CACERT=/opt/consul/tls/consul-agent-ca.pem
CONSUL_HTTP_SSL=true
CONSUL_HTTP_ADDR=<dc-1-server-ip>:8501
Now create the systemd service by running following command. Change by the token create in step 6 above.

sudo tee /etc/systemd/system/envoy.service > /dev/null << "EOF"
[Unit]
Description=Envoy
After=network-online.target
Wants=consul.service
[Service]
EnvironmentFile=/etc/consul.d/envoy.env
ExecStart=/usr/bin/consul connect envoy -expose-servers -gateway=mesh -register -service "mesh-gateway” -address "10.0.4.206:443" -wan-address "15.237.122.152:443" -token 76a0dc42-7c0c-b8d9-7383-283be4dd2039 -tls-server-name “server.dc1.consul" -- -l debug
Restart=always
RestartSec=5
StartLimitIntervalSec=0
[Install]
WantedBy=multi-user.target
EOF


sudo systemctl enable envoy.service
sudo systemctl start envoy.service
Check the good functioning of the service by running journalctl -e -u consul and journalctl -e -u envoy Also log in to the consul UI and check that all services are healthy and green :)

Setup of the secondary DC
Create a replication token. Before we start setting up the second DC we need to create a token for the Consul servers in the secondary DC. This will give them persmissions to replicate the information (ACL´s, intentions etc..) from the primary DC
sudo tee /opt/consul/policies/replication-policy.hcl > /dev/null << EOF
acl = "write"

operator = "write"

service_prefix "" {
  policy = "read"
  intentions = "read"
}

consul acl policy create \
  -token=${CONSUL_MGMT_TOKEN} \
  -name replication-policy \
  -rules @/opt/consul/policies/replication-policy.hcl

consul acl token create \
  -token=${CONSUL_MGMT_TOKEN} \
  -description "replication token" \
  -policy-name replication-policy
Copy the CA certificate located from the server of the primary DC to the first server of the secondary DC The file is located in */opt/consul/tls of DC-1-Server. Copy the CA Certificate to the same directory on the secondary server.
From within the tls directory run the following commands

consul tls cert create -server -dc dc2 -node "*"
consul tls cert create -client -dc dc2
Set the configuration of the secondary DC Server 1. *Change the to the public IP address of the mesh gateway from the primary DC setup above. *Change the <enc_key> to the same encryption key used above.
Run the following on the server:

sudo tee /etc/consul.d/consul.hcl > /dev/null << "EOF"
datacenter = "dc-2"
primary_gateways = ["<primary-gw-ip>:443"]
primary_datacenter = "dc-1"
client_addr = "0.0.0.0"
data_dir = "/opt/consul"
license_path = "/opt/consul/consul.hclic"
encrypt = "<enc_key>"
ca_file = "/opt/consul/tls/consul-agent-ca.pem"
cert_file = "/opt/consul/tls/dc2-server-consul-0.pem"
key_file = "/opt/consul/tls/dc2-server-consul-0-key.pem"
verify_incoming = true
verify_outgoing = true
verify_server_hostname = true
server = true
bootstrap_expect = 1
ui = true
enable_central_service_config = true
auto_encrypt {
  allow_tls = true
}
acl = {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
  tokens {
    agent = "dc323b5f-89ba-34c3-0c79-021607323e19"
    replication = "dc323b5f-89ba-34c3-0c79-021607323e19"
  }

}
ports {
 grpc = 8502,
 https = 8501
}
connect {
  enabled = true
  enable_mesh_gateway_wan_federation = true
}
EOF
Enable and start consul
sudo systemctl enable consul
sydo systemctl start consul
Check for any errors errors. You will see errors appear in the beginning as it takes time for the ACLs to be copied over. Also you will see some connection errors which is because the meshgateway still needs to be started for the secondary DC.

systemctl -e -u consul
Configure and start the secondary meshgateway instance Run the following command. Replace with the node token created in the first DC Replace with the encryption key created in the first DC
sudo tee /etc/consul.d/consul.hcl  > /dev/null << "EOF"
datacenter = "dc-2"
primary_datacenter = "dc-1"
connect = {
  enabled = true
}
data_dir = "/opt/consul/data"
log_level = "INFO"
retry_join = ["provider=aws tag_key=consulserver tag_value=dc-2"]
ca_file = "/opt/consul/tls/consul-agent-ca.pem"
verify_incoming = false
verify_outgoing = true
verify_server_hostname = true
auto_encrypt = {
  tls = true
}
acl {
  enabled        = true
  default_policy = "deny"
  down_policy    = "extend-cache"

  tokens {
    "agent" = "<node-token>"
  }
}
ports {
 grpc = 8502
}
encrypt = "<enc-key>"
EOF
Enable and start envoy Run the following command: Replace with the intenral IP address of the instance running this server Replace with the external IP address of the instance running this server Replace witgh the mgw token created in DC1
sudo tee /etc/systemd/system/envoy.service > /dev/null << "EOF"
[Unit]
Description=Envoy
After=network-online.target
Wants=consul.service
[Service]
ExecStart=/usr/bin/consul connect envoy -expose-servers -gateway=mesh -register -service "mesh-gateway2" -address "<mgw2-internal-ip>:443" -wan-address "<mgw2-external-ip>:443" -token <mgw-token> -tls-server-name "server.dc2.consul" -- -l debug
Restart=always
RestartSec=5
StartLimitIntervalSec=0
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable envoy.service
sudo systemctl start envoy.service
Check the envoy service has been started succesfully: a. Check the interface b. Run the following command and check for any errors: journalctl -e -u consul

You have now setup 2 wa federated DC´s with