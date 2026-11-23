# Through vCenter, data sources look objects up BY NAME. vCenter can manage many
# datacenters and hosts, so "the default one" no longer exists.

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
