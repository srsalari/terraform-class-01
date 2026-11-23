output "vm_name" {
  value = vsphere_virtual_machine.vm.name
}

output "vm_power_state" {
  description = "poweredOn, poweredOff or suspended"
  value       = vsphere_virtual_machine.vm.power_state
}

output "vm_moid" {
  description = "Managed object ID. Watch it when the VM is replaced"
  value       = vsphere_virtual_machine.vm.moid
}

output "vm_uuid" {
  value = vsphere_virtual_machine.vm.uuid
}
