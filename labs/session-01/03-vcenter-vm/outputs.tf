output "vm_name" {
  value = vsphere_virtual_machine.vm.name
}

output "vm_moid" {
  description = "Managed object ID in vCenter (e.g. vm-1042). Compare with Lab 1.2"
  value       = vsphere_virtual_machine.vm.moid
}

output "vm_folder" {
  value = vsphere_folder.lab.path
}

output "datacenter_moid" {
  value = data.vsphere_datacenter.dc.id
}
