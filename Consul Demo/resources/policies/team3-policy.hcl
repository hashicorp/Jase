namespace "k8s-team3" {
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
