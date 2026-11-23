variable "student" {
  description = "Your ID, used as a prefix for everything you create (e.g. s01). Must be unique on a shared host."
  type        = string
}

variable "datastore" {
  description = "Datastore for the VM disk"
  type        = string
  default     = "datastore1"
}

variable "network" {
  description = "Port group the VM connects to"
  type        = string
  default     = "VM Network"
}

# Leave these two unset when VSPHERE_SERVER is an ESXi host.
# Set them only if your host is managed by a vCenter that blocks direct logins
# (lockdown mode) and you point VSPHERE_SERVER at that vCenter instead.
variable "datacenter" {
  description = "vCenter only: datacenter name. Ignored by a standalone ESXi host"
  type        = string
  default     = null
}

variable "host" {
  description = "vCenter only: the ESXi host as listed in vCenter. Not needed on a standalone ESXi host"
  type        = string
  default     = null
}
