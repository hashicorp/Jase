# deny everything for anonymous
  namespace_prefix "" {
    key_prefix "" {
      policy = "deny"
    }    
    node_prefix "" {
       policy = "deny"
    }
    service_prefix "" {
       policy = "deny"
    }
  }