service {
  name = "backend"
  id = "backend-1"
  port = 9090
  tags = ["v1"]

  connect { 
    sidecar_service {
      proxy {
      }
    }
  }
  token = "c1ca7e87-5cfb-a17e-aefb-5d6582953194"
}