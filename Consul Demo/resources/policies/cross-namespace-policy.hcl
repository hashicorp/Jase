  namespace "default" {
    key_prefix "" {
      policy = "deny"
    }          
    service_prefix "" {
      policy = "deny"
    }
    node_prefix "" {
      policy = "deny"
    }
  }

# this is the namespace which should be readable by all teams
namespace "k8s-base" {
    key_prefix "" {
      policy = "read"
    }        
    service_prefix "" {
      policy = "read"
      intentions="deny"
    }
    node_prefix "" {
      policy = "read"
    }       
  }