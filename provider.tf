provider "aws" {
  region     = "us-east-1"
}

terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "cloudilm-dev"

    workspaces {
      name = "terraform-cloud-lab-2"
    }
  }
}
