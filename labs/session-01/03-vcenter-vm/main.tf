# Two resources this time. The folder only exists in vCenter: a standalone ESXi
# host has no VM folders.

resource "vsphere_folder" "lab" {
  path          = "${var.student}-lab"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name = "${var.student}-vc-vm01"

  # A reference to another resource: Terraform creates the folder first.
  folder = vsphere_folder.lab.path

  # Every host (and every cluster) has a root resource pool. This works for a
  # single host; with a cluster you would use data.vsphere_compute_cluster.
  resource_pool_id = data.vsphere_host.esxi.resource_pool_id
  host_system_id   = data.vsphere_host.esxi.id
  datastore_id     = data.vsphere_datastore.ds.id

  num_cpus = 1
  memory   = 512
  guest_id = "ubuntu64Guest"

  network_interface {
    network_id   = data.vsphere_network.net.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = 8
    thin_provisioned = true
  }

  wait_for_guest_net_timeout = 0
}
