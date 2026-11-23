# Data sources READ existing objects from the ESXi host. Terraform never creates,
# changes or deletes them, and they don't have to be managed by Terraform.

# Connected straight to ESXi (no vCenter), the host has one built-in datacenter
# called ha-datacenter. An empty block returns it; a name would be ignored.
data "vsphere_datacenter" "dc" {}

data "vsphere_datastore" "ds" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "net" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Connected straight to ESXi there is exactly one host: this one. The name can
# be left out. Its root resource pool is where ESXi puts every VM.
data "vsphere_host" "esxi" {
  datacenter_id = data.vsphere_datacenter.dc.id
}
