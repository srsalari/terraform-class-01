# A resource block CREATES and MANAGES an object. Terraform owns its lifecycle.
#
# This VM is built from scratch: an empty disk and no operating system yet.
# (Cloning from a template needs vCenter, which this lab does not use.)
# It is small on purpose: it fits on a laptop's nested ESXi as well.

resource "vsphere_virtual_machine" "vm" {
  name             = "${var.student}-vm01"
  resource_pool_id = data.vsphere_host.esxi.resource_pool_id
  datastore_id     = data.vsphere_datastore.ds.id

  num_cpus = 1
  memory   = 2048
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

  cdrom {
    datastore_id = data.vsphere_datastore.ds.id
    path         = "iso/ubuntu-26.04.1-live-server-amd64.iso"
  }
  # No OS means no VMware Tools and no IP address, so don't wait for one.
  wait_for_guest_net_timeout = 0
}
