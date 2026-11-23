# Same provider as Lab 1.2. Only the endpoint and the user change:
#   VSPHERE_SERVER                the vCenter, e.g. 192.168.100.20 (not the ESXi host)
#   VSPHERE_USER                  e.g. administrator@vsphere.local, or your vCenter user
#   VSPHERE_PASSWORD
#   VSPHERE_ALLOW_UNVERIFIED_SSL  true for lab vCenters with self-signed certificates
provider "vsphere" {}
