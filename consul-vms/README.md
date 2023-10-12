![](Files/Consul_Enterprise_Logo_Color_RGB.svg)

**Disclaimer: This setup is for POC purposes and not fit for production**

#   Consul POC Guide


- Install consul client

Install Consul Binary
Debian-based instructions:

```
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/hashicorp.gpg
chmod go-w /etc/apt/trusted.gpg.d/hashicorp.gpg
chmod ugo+r /etc/apt/trusted.gpg.d/hashicorp.gpg

apt-add-repository -y "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

apt update && apt install -y unzip consul-enterprise jq net-tools

```
Install Envoy Binary
VM / Bare metal
For non-kubernetes, the Envoy binary will need to be acquired and pushed to the workloads. 
Downloading Envoy binaries can be a lot more challenging than you’d expect.
get-envoy was the standard, but is now discontinued due to trademark issues.

Debian-based instructions:


```
https://www.envoyproxy.io/docs/envoy/latest/start/install —-> envoy install URL


$ sudo apt update

$ sudo apt install apt-transport-https gnupg2 curl lsb-release


$ curl -sL 'https://deb.dl.getenvoy.io/public/gpg.8115BA8E629CC074.key' | sudo gpg --dearmor -o /usr/share/keyrings/getenvoy-keyring.gpg


# Verify the keyring - this should yield "OK"

$ echo a077cb587a1b622e03aa4bf2f3689de14658a9497a9af2c427bba5f4cc3c4723 /usr/share/keyrings/getenvoy-keyring.gpg | sha256sum --check


$ echo "deb [arch=amd64 signed-by=/usr/share/keyrings/getenvoy-keyring.gpg] https://deb.dl.getenvoy.io/public/deb/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/getenvoy.list


$ sudo apt update

$ sudo apt install getenvoy-envoy

envoy --version

```


## STEP BY STEP GUIDE on Installing Consul on VM´s with full zero trust and TLS. 
This guide describes the following:
- How top install a secure DC.
- TLS is enabled everywhere
- Default Deny
- Auto Encrypt
### Setup of DC1


The consul.hcl for DC1 will look something like this:
```
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Full configuration options can be found at https://www.consul.io/docs/agent/config

# datacenter
# This flag controls the datacenter in which the agent is running. If not provided,
# it defaults to "dc1". Consul has first-class support for multiple datacenters, but 
# it relies on proper configuration. Nodes in the same datacenter should be on a 
# single LAN.
node_name = "consul-server1-dc1"
datacenter = "dc1"

log_level = "INFO"

peering { enabled = true }

# data_dir
# This flag provides a data directory for the agent to store state. This is required
# for all agents. The directory should be durable across reboots. This is especially
# critical for agents that are running in server mode as they must be able to persist
# cluster state. Additionally, the directory must support the use of filesystem
# locking, meaning some types of mounted folders (e.g. VirtualBox shared folders) may
# not be suitable.
data_dir = "/consul/data"

#addresses = {
#  dns = "0.0.0.0"
#  http = "0.0.0.0"
#  https = "0.0.0.0"
#  grpc = "0.0.0.0"
#  grpc_tls = "0.0.0.0"
#}

# client_addr
# The address to which Consul will bind client interfaces, including the HTTP and DNS
# servers. By default, this is "127.0.0.1", allowing only loopback connections. In
# Consul 1.0 and later this can be set to a space-separated list of addresses to bind
# to, or a go-sockaddr template that can potentially resolve to multiple addresses.
client_addr = "0.0.0.0"

# ui
# Enables the built-in web UI server and the required HTTP routes. This eliminates
# the need to maintain the Consul web UI files separately from the binary.
# Version 1.10 deprecated ui=true in favor of ui_config.enabled=true
ui_config{
  enabled = true

  metrics_provider = "prometheus"
  metrics_proxy = {
    base_url = "http://10.5.0.200:9090"
  }
}

# server
# This flag is used to control if an agent is in server or client mode. When provided,
# an agent will act as a Consul server. Each Consul cluster must have at least one
# server and ideally no more than 5 per datacenter. All servers participate in the Raft
# consensus algorithm to ensure that transactions occur in a consistent, linearizable
# manner. Transactions modify cluster state, which is maintained on all server nodes to
# ensure availability in the case of node failure. Server nodes also participate in a
# WAN gossip pool with server nodes in other datacenters. Servers act as gateways to
# other datacenters and forward traffic as appropriate.
server = true

# Bind addr
# You may use IPv4 or IPv6 but if you have multiple interfaces you must be explicit.
#bind_addr = "[::]" # Listen on all IPv6
#bind_addr = "0.0.0.0" # Listen on all IPv4
#
# Advertise addr - if you want to point clients to a different address than bind or LB.
#advertise_addr = "172.31.27.191"   # "127.0.0.1"
# advertise_addr_wan = "54.228.176.154"
advertise_addr = "{{ GetDefaultInterfaces | exclude \"type\" \"IPv6\" | attr \"address\" }}"
client_addr = "0.0.0.0"


ports = {
  grpc = 8502
  https = 8501
# http = -1
  grpc_tls = 8503
# dns = 8600
}

# Enterprise License
# As of 1.10, Enterprise requires a license_path and does not have a short trial.
license_path = "/etc/consul.d/consul.hclic"

# bootstrap_expect
# This flag provides the number of expected servers in the datacenter. Either this value
# should not be provided or the value must agree with other servers in the cluster. When
# provided, Consul waits until the specified number of servers are available and then
# bootstraps the cluster. This allows an initial leader to be elected automatically.
# This cannot be used in conjunction with the legacy -bootstrap flag. This flag requires
# -server mode.
bootstrap_expect=1

# encrypt
# Specifies the secret key to use for encryption of Consul network traffic. This key must
# be 32-bytes that are Base64-encoded. The easiest way to create an encryption key is to
# use consul keygen. All nodes within a cluster must share the same encryption key to
# communicate. The provided key is automatically persisted to the data directory and loaded
# automatically whenever the agent is restarted. This means that to encrypt Consul's gossip
# protocol, this option only needs to be provided once on each agent's initial startup
# sequence. If it is provided after Consul has been initialized with an encryption key,
# then the provided key is ignored and a warning will be displayed.
encrypt = "oxFP6MiiCV58b0eeRXfPP7kc5db9wInyvM0zhig2Vxg="

# retry_join
# Similar to -join but allows retrying a join until it is successful. Once it joins 
# successfully to a member in a list of members it will never attempt to join again.
# Agents will then solely maintain their membership via gossip. This is useful for
# cases where you know the address will eventually be available. This option can be
# specified multiple times to specify multiple agents to join. The value can contain
# IPv4, IPv6, or DNS addresses. In Consul 1.1.0 and later this can be set to a go-sockaddr
# template. If Consul is running on the non-default Serf LAN port, this must be specified
# as well. IPv6 must use the "bracketed" syntax. If multiple values are given, they are
# tried and retried in the order listed until the first succeeds. Here are some examples:
#retry_join = ["consul.domain.internal"]
#retry_join = ["10.0.4.67"]
#retry_join = ["[::1]:8301"]
#retry_join = ["consul.domain.internal", "10.0.4.67"]
# Cloud Auto-join examples:
# More details - https://www.consul.io/docs/agent/cloud-auto-join
#retry_join = ["provider=aws tag_key=... tag_value=..."]
#retry_join = ["provider=azure tag_name=... tag_value=... tenant_id=... client_id=... subscription_id=... secret_access_key=..."]
#retry_join = ["provider=gce project_name=... tag_value=..."]
#retry_join = ["172.31.27.191"] 
retry_join = ["172.31.27.191"] # , "172.31.18.129", "172.31.21.146"] 

acl {
  enabled = true
  default_policy = "allow"
  down_policy = "extend-cache"
  enable_token_persistence = true

  tokens {
    initial_management = "MyC00lT0ken"
#    agent = "MyC00lT0ken"
#    default = ""
  }
}

auto_encrypt = {
  allow_tls = true
}


tls {
  defaults {
    ca_file = "/consul/config/certs/consul-agent-ca.pem"
    cert_file = "/consul/config/certs/dc1-server-consul-0.pem"
    key_file = "/consul/config/certs/dc1-server-consul-0-key.pem"

    verify_incoming = true
    verify_outgoing = true
  }
  internal_rpc {
    verify_server_hostname = true
  }
}

auto_reload_config = true

```

Create Consul Server Agent RPC certificates

The exported CA cert and key from the  primary, need to be in the same directory when running this command:

```
Consul keygen —---> keep for all servers & clients  # will create a gossip key to use as the encrpt key in the agent file
encrypt = "mnq9VuskJYWOZI+fiZTsX/4uLtiHlw5r48YRDZSHMLg="

sudo consul tls ca create

consul tls cert create -server -dc <my dc-name>

Copy Server Agent Certs and CA Cert to Consul Config directory

sudo mkdir -p /consul/config
sudo mv vm-secondary-server-consul-0* /consul/config/certs
sudo mv consul-agent-ca.pem /consul/config/certs
```

```
Change ownership of files to consul (no root or will fail to execute)

Copy enterprise license contents to: /etc/consul.d/consul.hclic

sudo chown -R consul:consul /consul
sudo chown -R consul:consul /etc/consul.d
sudo chown -R consul:consul /consul/config
sudo chown -R consul:consul /consul/config/certs
sudo chown -R consul:consul /consul/config/policies

export CONSUL_HTTP_ADDR=https://127.0.0.1:8501 # or 8500 (TLS or not)
export CONSUL_HTTP_TOKEN=mnq9VuskJYWOZI+fiZTsX/4uLtiHlw5r48YRDZSHMLg=

```
# START CONSUL

```
systemctl enable consul

sudo systemctl consul start or sudo consul agent -config-dir=/etc/consul.d/
sudo systemctl consul status

```

```
create an anonymous_policy.hcl (need to be root -----> sudo su -) copy and run in the shell


cat <<EOT > /root/anonymous_policy.hcl
agent_prefix "" {
  policy = "read"
}
node_prefix "" {
  policy = "read"
}
service_prefix "" {
  policy = "read"
}
key_prefix "" {
  policy = "read"
}
EOT

consul acl policy create -name "anonymous-policy" \
  -description "This is the anonymous policy" \
  -rules @/root/anonymous_policy.hcl

consul acl token update \
  -id anonymous \
  -policy-name anonymous-policy

```


Bootstrap DC1 Server Run following command: 

```
consul acl bootstrap

You will see an outbput that looks like this:

AccessorID:   4d123dff-f460-73c3-02c4-8dd64d136e01
SecretID:     86cddfb9-2760-d947-358d-a2811156bf31
Description:  Bootstrap Token (Global Management)
Local:        false
Create Time:  2018-10-22 11:27:04.479026 -0400 EDT
Policies:
   00000000-0000-0000-0000-000000000001 - global-management

```

Copy the secret ID and store this in the environment variables CONSUL_HTTP_TOKEN and CONSUL_MGMT_TOKEN by running folling command. Replace <bootstrap_token> by the token copied above




```
export CONSUL_HTTP_ADDR=172.31.27.191:8500 # the private IP address or loopback of exposed server
export CONSUL_HTTP_TOKEN="<bootstrap_token>"
export CONSUL_MGMT_TOKEN="<bootstrap_token>"
```
NOTE: The bootstrap token is like a 'root access' to your system and should only be used for initial bootstrap. Store it safely.


Before we can install and register any new node we need to create a node policy. Run the following command on the DC Server

```
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
```
```
consul acl policy create \
  -token=${CONSUL_MGMT_TOKEN} \
  -name node-policy \
  -rules @/opt/policies/nodepolicy.hcl

consul acl token create \
  -token=${CONSUL_MGMT_TOKEN} \
  -description "node token” \
  -policy-name node-policy
```

## Installing Consul on 2nd & 3rd Server VM´s with full zero trust and TLS. 

the 2nd and 3rd server config can be found in this repo ----> link shown below

```
https://github.dev/hashicorp/Jase/tree/main/consul-vms

Update the encrpyt key that you got from the bootstrap command for server 1 and  within the hcl config file update ----> encrypt = "mnq9VuskJYWOZI+fiZTsX/4uLtiHlw5r48YRDZSHMLg=

copy the certificates that you created with server 1 and put them in the certificat location that you created

    ca_file = "/consul/config/certs/consul-agent-ca.pem"
    cert_file = "/consul/config/certs/dc1-server-consul-0.pem"
    key_file = "/consul/config/certs/dc1-server-consul-0-key.pem"


update the ownerership of the directories to consul

sudo chown -R consul:consul /consul
sudo chown -R consul:consul /etc/consul.d
sudo chown -R consul:consul /consul/config
sudo chown -R consul:consul /consul/config/certs

```
# REPEAT FOR SERVER 3


# START CONSUL FOR SERVER 2 & 3

```
systemctl enable consul

sudo systemctl consul start or sudo consul agent -config-dir=/etc/consul.d/
sudo systemctl consul status

```

# RETURN TO SERVER 1
# WITHIN CONSUL.HCL CHANGE BOOSTRAP-EXPECT =3 FROM 1 
# WITHIN CONSUL.HCL CHANGE retry_join = ["172.31.27.191"], "172.31.18.129", "172.31.21.146"]  INCLUDE ALL 3 SERVERS

```
change to directory ----> /etc/consul.d/
consul reload
```



CREATE A CLIENT VM NODE & SERVICE TO REGISTER INTO THE CONSUL SERVER/CATALOGUE

Install Consul Binary
Debian-based instructions:

```
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/hashicorp.gpg
chmod go-w /etc/apt/trusted.gpg.d/hashicorp.gpg
chmod ugo+r /etc/apt/trusted.gpg.d/hashicorp.gpg

apt-add-repository -y "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

apt update && apt install -y unzip consul-enterprise jq net-tools

```
Install Envoy Binary
VM / Bare metal
For non-kubernetes, the Envoy binary will need to be acquired and pushed to the workloads. 
Downloading Envoy binaries can be a lot more challenging than you’d expect.
get-envoy was the standard, but is now discontinued due to trademark issues.

Debian-based instructions:


```
https://www.envoyproxy.io/docs/envoy/latest/start/install —-> envoy install URL


$ sudo apt update

$ sudo apt install apt-transport-https gnupg2 curl lsb-release


$ curl -sL 'https://deb.dl.getenvoy.io/public/gpg.8115BA8E629CC074.key' | sudo gpg --dearmor -o /usr/share/keyrings/getenvoy-keyring.gpg


# Verify the keyring - this should yield "OK"

$ echo a077cb587a1b622e03aa4bf2f3689de14658a9497a9af2c427bba5f4cc3c4723 /usr/share/keyrings/getenvoy-keyring.gpg | sha256sum --check


$ echo "deb [arch=amd64 signed-by=/usr/share/keyrings/getenvoy-keyring.gpg] https://deb.dl.getenvoy.io/public/deb/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/getenvoy.list


$ sudo apt update

$ sudo apt install getenvoy-envoy

envoy --version

```

CLIENT AGENT HCL CONFIG FILE

```
# this will create the node & register in consul ready  for the service to run on

node_name = "client-dc1-alpha"
datacenter = "dc1"
partition = "default"

data_dir = "/consul/data"
log_level = "INFO"
retry_join = ["172.31.27.191"] # ["consul-server1-dc1"]
# retry_join = ["consul-server1-dc1"]

encrypt = "oxFP6MiiCV58b0eeRXfPP7kc5db9wInyvM0zhig2Vxg=" # the gossip key created by the consul server ##########

server = false
advertise_addr = "10.0.1.252"
bind_addr = "{{ GetDefaultInterfaces | exclude \"type\" \"IPv6\" | attr \"address\" }}"
client_addr = "0.0.0.0"
ui = true

telemetry {
  prometheus_retention_time = "10m"
  disable_hostname = true
}

acl {
  enabled = true
  default_policy = "deny"
  enable_token_persistence = true
  tokens {
    initial_management = "MyC00lT0ken"
    agent = "MyC00lT0ken"
  }
}

auto_encrypt {
  tls = true
}

tls {
  defaults {
    ca_file = "/etc/consul.d/consul-agent-ca.pem" ###### copy from server1  ca_file  #########

    verify_incoming = true
    verify_outgoing = true
  }
  internal_rpc {
    verify_server_hostname = true
  }
}

ports = {
  grpc = 8502
  https = 8501
  grpc_tls = 8503
}

# retry_join = ["provider=aws tag_key=role tag_value=consul-server"]
```

THE NODE SHOULD NOW BE REGISTERED WITH CONSUL & NOW TO ADD THE SERVICE

```
# cat file, then copy the output and paste into shell to run mysql Service
# Install fake-service
mkdir -p /opt/fake-service
wget https://github.com/nicholasjackson/fake-service/releases/download/v0.26.0/fake_service_linux_amd64.zip
unzip -od /opt/fake-service/ fake_service_linux_amd64.zip
rm -f fake_service_linux_amd64.zip
chmod +x /opt/fake-service/fake-service

# Configure a service on the VM
cat <<EOT > /etc/systemd/system/mysql.service
[Unit]
Description=mysql
After=syslog.target network.target

[Service]
Environment=NAME="mysql"
Environment=MESSAGE="Product DB MySQL"
Environment=LISTEN_ADDR="0.0.0.0:3306"
ExecStart=/opt/fake-service/fake-service
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOT



cat <<EOT > /etc/consul.d/mysql.hcl
service {
  name = "mysql"
  port = 3306
  tags = ["mysql", "sql", "product", "db"]
  meta = {
    product = "MySQL"
    version = "8.0.34"
    owner   = "dba@acme.com"
  } 

  checks = [
    {
      name = "SQL Server Check on port 3306"
      tcp = "127.0.0.1:3306"
      interval = "10s"
      timeout = "5s"
    }
  ]
  token = "c57385c9-a1a9-017a-bdf5-74e4241f0d27" # client token or token with permissions
}
EOT

```

![image](https://github.com/hashicorp/Jase/assets/81739850/c8938135-5706-4c2c-98ae-a02f211622ec)





Copy the secret id from the node token and run the following command consul acl set-agent-token agent "<node token>"

On the mesh gateway server run the following commands:
Replace with the ndoe token created above
Replace with the encryption key found on dc-1-server

```
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
```

In order for a mesh-gateway to register itself as a service it needs to have a token that allows it to do so.
sudo tee /opt/consul/policies/mgw.hcl > /dev/null << EOF

```
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
```
```
consul acl policy create \
  -token=${CONSUL_MGMT_TOKEN} \
  -name mgw-policy \
  -rules @/opt/consul/policies/mgw.hcl

consul acl token create \
  -token=${CONSUL_MGMT_TOKEN} \
  -description “mgw token" \
  -policy-name mgw-policy
```
You will need the secret id (token) from that last command in a later step.

We will now set a default config for the services in across all DC´s to use the local meshgateway as a default. There are other options here. TODO: Add link
Run the following command

```
sudo tee /opt/policies/default-policy.hcl > /dev/null << "EOF"
Kind = "proxy-defaults"
Name = "global"
MeshGateway {
   Mode = "local"
}
EOF
```

```
consul config write /opt/policies/default-policy.hcl
```

We are now ready to start the envoy.
We will first set some environment variables which will be used by the systemd service.

Run the following command: Change the by the internal IP of the server for DC1

```
sudo tee /etc/consul.d/envoy.env > /dev/null << "EOF"
CONSUL_CACERT=/opt/consul/tls/consul-agent-ca.pem
CONSUL_HTTP_SSL=true
CONSUL_HTTP_ADDR=<dc-1-server-ip>:8501
```

Now create the systemd service by running following command. Change by the token create in step 6 above.

```
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
```

```
sudo systemctl enable envoy.service
sudo systemctl start envoy.service

```

Check the good functioning of the service by running 
```
journalctl -e -u consul and journalctl -e -u envoy
```

Also log in to the consul UI and check that all services are healthy and green :)


