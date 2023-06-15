# data "google_container_cluster" "gke_cluster" {
#   depends_on = [
#     google_container_node_pool.primary_nodes,
#   ]
#   name = google_container_cluster.primary.name
#   location = google_container_cluster.primary.location
# }

output "kubeconfig" {
  value = templatefile("${path.root}/templates/kubeconfig.yaml", {
    cluster_name = google_container_cluster.primary.name,
    endpoint =  google_container_cluster.primary.endpoint,
    user_name ="admin",
    cluster_ca = google_container_cluster.primary.master_auth.0.cluster_ca_certificate,
    client_cert = google_container_cluster.primary.master_auth.0.client_certificate,
    client_cert_key = google_container_cluster.primary.master_auth.0.client_key,
    # user_password = google_container_cluster.primary.master_auth.0.password,
    user_password = "",
    oauth_token = nonsensitive(data.google_client_config.current.access_token)
  })
  sensitive = true
}

output "ca_certificate" {
  value = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
}
output "cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
  # value = data.google_container_cluster.gke_cluster.endpoint
}
output "cluster_name" {
  depends_on = [
    google_container_node_pool.primary_nodes,
  ]
  # value = google_container_cluster.primary.name
  value = google_container_cluster.primary.name
}
output "gcp_zone" {
  value = google_container_cluster.primary.location
}