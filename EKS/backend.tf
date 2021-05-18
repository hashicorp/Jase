terraform {
  backend "remote" {
    organization = "jasonb"

    workspaces {
      name = "EKS-Workspace"
    }
  }
}
