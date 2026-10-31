terraform {
  required_version = ">= 1.0"

  required_providers {
    ubiops = {
      source  = "registry.terraform.io/ubiops/ubiops"
      version = "~> 0.1"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

# Token via UBIOPS_API_TOKEN ("Token <value>"), base URL via UBIOPS_BASE_URL.
# Kept out of code so secrets never land in git or state inputs.
provider "ubiops" {}
