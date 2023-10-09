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