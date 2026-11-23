terraform {
  # Which Terraform CLI versions may run this configuration
  required_version = ">= 1.12.0"

  # Which providers this configuration needs, and where to find them
  required_providers {
    random = {
      source  = "hashicorp/random" # short for registry.terraform.io/hashicorp/random
      version = "~> 3.6.0"           # >= 3.6.0 and < 4.0.0
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}
