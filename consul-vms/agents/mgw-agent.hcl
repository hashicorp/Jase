node_name = "client-dc1-mgw"
datacenter = "dc1"
partition = "default"

connect = {
  enabled = true
}

data_dir = "/consul/data"
log_level = "INFO"
retry_join = ["172.31.27.191"]

encrypt = "oxFP6MiiCV58b0eeRXfPP7kc5db9wInyvM0zhig2Vxg="

acl {
  enabled = true
  default_policy = "deny"
  down_policy    = "extend-cache"
  tokens {
    agent = "f4b5a78d-6f57-cce2-8fcb-b0a418ceb2c3"
    default = "f4b5a78d-6f57-cce2-8fcb-b0a418ceb2c3"
  }
}

ports {
 grpc = 8502
}


auto_encrypt = {
  tls = true
}

tls {
  defaults {
    ca_file = "/consul/config/certs/consul-agent-ca.pem"

    verify_incoming = false
    verify_outgoing = true
  }
  internal_rpc {
    verify_server_hostname = true
  }
}

auto_reload_config = true