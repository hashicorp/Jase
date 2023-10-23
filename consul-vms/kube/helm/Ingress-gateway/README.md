![](Files/Consul_Enterprise_Logo_Color_RGB.svg)

**Disclaimer: This setup is for POC purposes and not fit for production**

#   Consul POC Guide


![image](https://github.com/hashicorp/Jase/assets/81739850/f7cd24ef-5e80-4d3c-9f4c-e7ce54038294)

- Install consul client

Install Consul Binary & Envoy Binary plus toolsets
Debian-based instructions:

```
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/hashicorp.gpg
chmod go-w /etc/apt/trusted.gpg.d/hashicorp.gpg
chmod ugo+r /etc/apt/trusted.gpg.d/hashicorp.gpg

apt-add-repository -y "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

apt update && apt install -y unzip consul-enterprise hashicorp-envoy jq net-tools

consul --version
envoy --version

```


## STEP BY STEP GUIDE on Installing Consul on VM´s with full zero trust and TLS. 
This guide describes the following:
- How top install a secure DC.
- TLS is enabled everywhere
- Default Deny
- Auto Encrypt
### Setup of DC1