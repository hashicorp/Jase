log_level = "info"

consul {
  address = "34.252.230.154:8500"
# token   = "my-consul-acl-token"
}

driver "terraform" {
  log = true
  version = "0.14.0"
  required_providers {
    fortimanager = {
      source = "fortinetdev/fortimanager"
    }
  }
}

terraform_provider "fortimanager" {
    hostname     = "18.133.64.14"
    insecure     = "true"
    username     = "terraform"
    password     = "TerraFormConsole#"
    scopetype    = "adom" 
    adom         = "root"
}

task {
  name = "CTS-FM2"
  description = "Dynamic manage FortiManager Firewall address and address group by Consul_Terraform_Sync"
  module = "fortinetdev/cts-agpu/fortimanager" # to be updated
  providers = ["fortimanager"]
  services = ["FM2-Jason"]
  variable_files = ["./consul_test.tfvars"]
}