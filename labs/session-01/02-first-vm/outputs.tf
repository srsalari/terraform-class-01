# NOTE: this file is badly formatted ON PURPOSE. Lab step 3 fixes it with `terraform fmt`.
output "vm_name" {
  value = vsphere_virtual_machine.vm.name
}

output "vm_power_state" {
  description = "poweredOn, poweredOff or suspended"
  value       = vsphere_virtual_machine.vm.power_state
}

output "vm_moid" {
  description = "Managed object ID on the ESXi host (a number, e.g. 3)"
  value       = vsphere_virtual_machine.vm.moid
}

output "vm_uuid" {
  value = vsphere_virtual_machine.vm.uuid
}
