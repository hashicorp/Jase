module "gke" {

  count = var.numclusters

  source = "./modules/gke"
  gcp_region = var.gcp_region
  gcp_project = var.gcp_project
  node_type = var.node_type
  gcp_zone = var.gcp_zones[count.index]
  gke_cluster = "${var.gke_cluster}-${count.index}"
  numnodes = var.numnodes
  regional_k8s = var.regional_k8s
  owner = var.owner
  config_bucket = var.config_bucket
  default_gke = var.default_gke
  default_network = var.default_network
  k8s_version = var.k8s_version
}