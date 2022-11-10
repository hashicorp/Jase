job "traefik" {
  datacenters = ["dc1"]
  type        = "system"

  group "traefik" {
    network {
      mode = "host"
      port "http" {
        static = 80
        to = 80
      }
      port "api" {
        static = 8080
        to = 8080
      }
      port "ping" {
        static = 8082
        to = 8082
      }
      port "metrics" {
        static = 8083
        to = 8083
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik:2.9.1"
        args = ["--configFile=local/traefik.yaml"]
        ports = ["http", "api", "ping", "metrics"]
      }

      service {
        provider = "nomad"  ## Nomad service discovery!
        name = "traefik-admin"
        port = "api"
      }

      template {
        destination = "local/traefik.yaml"
        data = <<DATA
api:
  insecure: true
  dashboard: true
providers:
  nomad:
    endpoint:
      address: http://{{ env "attr.unique.network.ip-address" }}:4646
entryPoints:
  http:
    address: ":80"
  ping:
    address: ":8082"
  metrics:
    address: ":8083"
metrics:
  prometheus:
    entrypoint: "metrics"
DATA
      }

      service {
        provider = "nomad"
        name = "traefik"
        tags =["slb", "traefik", "demo"]
      }

      resources {
        cpu    = 250
        memory = 100
      }
    }
  }
}