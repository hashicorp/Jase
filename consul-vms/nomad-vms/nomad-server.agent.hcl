# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

# Full configuration options can be found at https://developer.hashicorp.com/nomad/docs/configuration

data_dir  = "/opt/nomad/data"
bind_addr = "172.31.30.79"

server {
  # license_path is required for Nomad Enterprise as of Nomad v1.1.1+
  license_path = "/etc/nomad.d/nomad.hclic"
  enabled          = true
  bootstrap_expect = 1
}

client {
  enabled = true
  servers = ["172.31.30.79"]
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}

acl {
  enabled = true
}


consul {
  address = "172.31.28.218:8500"
#  token   = "df179fd2-3211-3641-5901-a57331c14611"
  token   = "8e29317f-2f48-138b-665f-71054ade9dbe"
}  

service_identity {
    aud = ["consul.io"]
    ttl = "1h"
  }

  task_identity {
    aud = ["consul.io"]
    ttl = "1h"
  }
}

telemetry {
  publish_allocation_metrics = true
  publish_node_metrics       = true
}

audit {
  enabled = true
}
