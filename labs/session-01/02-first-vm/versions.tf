terraform {
  required_version = ">= 1.12.0"

  required_providers {
    vsphere = {
      # The provider moved from hashicorp/vsphere (frozen at 2.12) to vmware/vsphere.
      source  = "vmware/vsphere"
      version = "~> 2.17"
    }
  }
}
