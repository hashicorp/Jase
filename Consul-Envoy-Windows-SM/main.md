https://github.com/nicholasjackson/consul-envoy-windows/releases/tag/v0.0.1

# Envoy on Windows with Consul

Note: The paths configured in this example assume that c:/tmp is writable.
In this demo we assume an existing consul sever installation on k8s helm attached. 

## Get the certificate and envryption key from the existing consul DC
kubectl get secrets/consul-ca-cert -n consul --template='{{index .data "tls.crt" }}' | base64 --decode > consul-agent-ca.pem
kubectl get secret -n consul consul-gossip-encryption-key --template {{.data.key}} | base64 -d 

## (optional) Create an Agent token - Or use master token for testing bellow


## Create the directory structure for storing the config

```
$CONSUL_DIR = 'c:\consul'
New-Item -type directory $CONSUL_DIR\config
New-Item -type directory $CONSUL_DIR\data
New-Item -type directory $CONSUL_DIR\certs
New-Item -type file -Path "$CONSUL_DIR\config" -name consul.hcl
```
## create the config file

```
@"
datacenter = "dc1"
data_dir = "c:\consul\config\data"
encrypt = "Aej87Duj7rnoIogDACrP0A=="
verify_incoming = false
verify_outgoing = true
verify_server_hostname = true
ca_file = "c:\consul\certs/consul-agent-ca.pem"
auto_encrypt {
  tls = true
}
acl {
   enabled = true
   tokens {
    agent = "<token>"
   }
}

retry_join = ["192.168.5.8"]
ports {
 grpc = 8502
}
"@ | Out-File -Encoding ASCII -FilePath "${CONSUL_DIR}/config/consul.hcl"

```

## Run Consul server

Standalone
```
consul.exe agent --config-dir=C:/consul/config/
```
As windows Service

New-Service -Name Consul -BinaryPathName "$C:/windows/system32/consul.exe agent -config-dir=c:/consul/config"  -DisplayName Consul -Description "Hashicorp Consul Service https://consul.io" -StartupType "Automatic"




## Load the Consul config

```
.\consul.exe config write .\backend-defaults.hcl
```

### Envoy Bootstrap
This repo contains the required Envoy bootstrap config, however,
bootstrap config can also be generated with the following command:
If acls are enabled make sure to specify a token
```
consul.exe connect envoy --sidecar-for=backend-1 -bootstrap -token c1ca7e87-5cfb-a17e-aefb-5d6582953194 > bootstrap-backend.json
```

update the `access_log_path` as `/dev/null` is not available.

```json
  "admin": {
    "access_log_path": "c:/tmp/fake-access.log",
    "address": {
      "socket_address": {
        "address": "127.0.0.1",
        "port_value": 19000
      }
    }
  },
```

## Run Fake Backend and the associated Envoy
```
.\fake-service.exe
.\envoy.exe -c c:\tmp\bootstrap-backend.json
```

## Run Fake Frontend Envoy
This uses Consul as the registered service to 
bypass the need for running a real service, we only
want the service to start.

```
.\envoy.exe -c c:\tmp\bootstrap-frontend.json
```

## Test the service
Envoy has been configured to expose the backend service via
the frontend proxies local listener localhost:9091

```
curl "http://localhost:9091"
```
