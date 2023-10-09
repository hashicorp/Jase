cat <<EOT > /root/anonymous_policy.hcl
agent_prefix "" {
  policy = "read"
}
node_prefix "" {
  policy = "read"
}
service_prefix "" {
  policy = "read"
}
key_prefix "" {
  policy = "read"
}
EOT

consul acl policy create -name "anonymous-policy" \
  -description "This is the anonymous policy" \
  -rules @/root/anonymous_policy.hcl

consul acl token update \
  -id anonymous \
  -policy-name anonymous-policy