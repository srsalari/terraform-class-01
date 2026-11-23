# No credentials in code. The provider reads them from environment variables:
#   VSPHERE_SERVER                the ESXi host, e.g. 192.168.100.31 (no vCenter needed)
#   VSPHERE_USER                  e.g. root, or the ESXi user you were given
#   VSPHERE_PASSWORD
#   VSPHERE_ALLOW_UNVERIFIED_SSL  true for lab hosts with self-signed certificates
provider "vsphere" {}
