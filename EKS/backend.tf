terraform {
  backend "remote" {
    organization = "jonaa"

    workspaces {
      name = "Test-Workspace"
    }
  }
}