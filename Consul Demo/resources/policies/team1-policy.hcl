# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

namespace "k8s-team1" {
	key_prefix "" {
		policy = "write"
	}
	node_prefix "" {
		policy = "read"
	}    
	service_prefix "" {
		policy = "write"
		intentions = "write"
	}
}
