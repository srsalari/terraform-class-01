# Same data sources as Lab 1.2. On a standalone ESXi host the datacenter
# (ha-datacenter) and the host need no names.

data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_host" "esxi" {
  name          = var.host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "ds" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "net" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}
