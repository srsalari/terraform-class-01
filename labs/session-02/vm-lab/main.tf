# The VM from Lab 1.2. If you changed yours in Session 1 (for example more
# memory and a cdrom block to install Linux), copy YOUR main.tf over this file.

resource "vsphere_virtual_machine" "vm" {
  name             = "${var.student}-vm01"
  resource_pool_id = data.vsphere_host.esxi.resource_pool_id
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

  # No OS means no VMware Tools and no IP address, so don't wait for one.
  wait_for_guest_net_timeout = 0
}
