datacenter = "dc1"
data_dir = "c:/consul/config/data"
encrypt = "Aej87Duj7rnoIogDACrP0A=="
verify_incoming = false
verify_outgoing = true
verify_server_hostname = true
ca_file = "c:/consul/certs/consul-agent-ca.pem"
node_name = "consul-windows"
auto_encrypt {
  tls = true
}
acl {
   enabled = true
   tokens {
    agent = "27970967-1afc-4553-5dcf-ff8935a4390a"
   }
}
ports {
 grpc = 8502
}
retry_join = ["192.168.5.8"]
