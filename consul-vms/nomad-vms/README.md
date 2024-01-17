Disclaimer: This setup is for POC purposes and not fit for production

NOMAD Integration into Consul POC Guide


![Alt text](image.png)

Install Nomad client
Install Nomad Binary &  plus toolsets Debian-based instructions:

```
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install nomad-enterprise jq net-tools

CNI Plugins

curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.0.0/cni-plugins-linux-$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)"-v1.0.0.tgz && \
  sudo mkdir -p /opt/cni/bin && \
  sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz


```
```
nomad --version
```
```
nomad.hcl file

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

```


```
systemctl daemon-reload
systemctl enable nomad 
systemctl start nomad 

```

```
nomad acl boostrap

Accessor ID  = 6cc614f4-db5d-8022-e839-df99a5588bb0
Secret ID    = df6d3b3f-44d9-f774-24cd-a3e7c3953a7f
Name         = Bootstrap Token
Type         = management
Global       = true
Create Time  = 2024-01-17 15:25:02.674365346 +0000 UTC
Expiry Time  = <none>
Create Index = 12
Modify Index = 12
Policies     = n/a
Roles        = n/a

```

```

export NOMAD_TOKEN=df6d3b3f-44d9-f774-24cd-a3e7c3953a7f
export NOMAD_ADDR=34.250.234.108:4646

nomad server members
nomad node status


```

