# Terraform config to create a GKE cluster

This repository deploys a number of GKE clusters depending on some specific variables like:

* `default_network`: To use the default GCP network of your project (true|false). Defaults to `false`
* `default_gke`: If you want to use the default node pool from GKE deployment (true|false). Defaults to `false`
* `gcp_project`: Your GCP project to deploy your GKE clusters
* `gcp_region`: The GCP region to deploy
* `gcp_zone`: A list with the zones where you want to deploy your clusters. Size of the list needs to be the same as the number of clusters (TODO: improve the code to remove this constraint)
* `gke_cluster`: Prefix name for your clusters. Then and index number will be added as a suffix (*mycluster-0*, *mycluster-1*, etc...)
* `k8s_version`: A major Kubernetes version to use. Defaults to `1.22`
* `node_type`: The VM type to use in GCP for the nodes. Defaults to `n2-standard-2`
* `numclusters`: Number of GKE clusters to deploy
* `numnodes`: Number of nodes of each cluster. Defaults to `3`
* `owner`: This is an owner tag to be added to resources
* `regional_k8s`: Set this to true if you want to deploy a regional GKE cluster (nodes spread to different zones). Defaults to `false`
