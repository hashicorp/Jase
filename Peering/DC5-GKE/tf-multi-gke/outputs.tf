# data "google_container_cluster" "gke_cluster" {
#   depends_on = [
#     google_container_node_pool.primary_nodes,
#   ]
#   name = google_container_cluster.primary.name
#   location = google_container_cluster.primary.location
# }

# locals {

# }

output "kubeconfig" {
  value = module.gke[*].kubeconfig
  sensitive = true
}

output "ca_certificate" {
  value = module.gke[*].ca_certificate
}
output "cluster_endpoint" {
  value = module.gke[*].cluster_endpoint
  # value = data.google_container_cluster.gke_cluster.endpoint
}
output "cluster_name" {
  # value = google_container_cluster.primary.name
  value = module.gke[*].cluster_name
}
output "gcp_zone" {
  value = module.gke[*].gcp_zone
}

output "gcloud_command" {
  value = [ for i in range(length(module.gke[*].cluster_name)) : "gcloud container clusters get-credentials ${module.gke[i].cluster_name} --zone ${module.gke[i].gcp_zone}"]
}