#!/bin/sh
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


## Install Hashicorp repo
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

## Install Packages
apt update && apt install -y docker.io unzip nomad

## Install Nomad beta (1.4 is GA!)
# curl -O nomad.zip https://releases.hashicorp.com/nomad/1.4.0-beta.1/nomad_1.4.0-beta.1_linux_amd64.zip
# unzip -od /usr/bin/ nomad.zip 

# Configure a smaller range of ports for dynamic workloads in line with Vagrantfile
cat <<EOF > /etc/nomad.d/extra_config.hcl
client {
  min_dynamic_port = 20000
  max_dynamic_port = 20030
}

plugin "docker" {
  config {
    volumes {
      enabled = true
    }
  }
}
EOF

systemctl daemon-reload
systemctl enable nomad --now
systemctl enable docker --now

# Pull required containers
docker pull mysql:8.0.31 
docker pull traefik:2.9.1
docker pull wordpress:6.0.2
