Disclaimer: This setup is for POC purposes and not fit for production

NOMAD POC Guide


![Alt text](image.png)

Install Nomad client
Install Nomad Binary &  plus toolsets Debian-based instructions:

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
 echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
 sudo apt update && sudo apt install nomad-enterprise jq net-tools



nomad --version
