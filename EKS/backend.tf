# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  backend "remote" {
    organization = "emea-se-playground-2019"

    workspaces {
      name = "Jason-EKS"
    }
  }
}
