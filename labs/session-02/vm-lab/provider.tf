# No credentials in code. The provider reads them from environment variables:
#   VSPHERE_SERVER                your workplace ESXi host (or its vCenter, see variables.tf)
#   VSPHERE_USER                  root, or an ESXi user that can create, change and delete VMs
#   VSPHERE_PASSWORD
#   VSPHERE_ALLOW_UNVERIFIED_SSL  true for self-signed certificates
provider "vsphere" {}
