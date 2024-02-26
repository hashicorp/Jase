# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

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