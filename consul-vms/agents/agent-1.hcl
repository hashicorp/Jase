# this will create the node & register in consul ready  for the service to run on

node_name = "client-dc1-alpha"
datacenter = "dc1"
partition = "default"

license_path = "/etc/consul.d/consul.hclic"

data_dir = "/consul/data"
log_level = "INFO"
retry_join = ["172.31.27.191"] # ["consul-server1-dc1"]
# retry_join = ["consul-server1-dc1"]

encrypt = "oxFP6MiiCV58b0eeRXfPP7kc5db9wInyvM0zhig2Vxg=" # the gossip key created by the consul server

server = false
advertise_addr = "172.31.26.58" # local IP address of client
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
    ca_file = "/etc/consul.d/consul-agent-ca.pem" # copy from server1  ca_file

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
