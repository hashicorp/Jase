# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# token= "a5c882f6-02b5-95ea-8698-8189b55abacc"
template {
  source = "dns.tmpl"
  destination = "zone.db"
  # command= "named-checkconf && named-checkzone methridge.dev zone.db && rndc reload"
}

