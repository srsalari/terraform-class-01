variable "student" {
  description = "Your ID, used as a prefix for everything you create (e.g. s01)"
  type        = string
}

variable "datacenter" {
  description = "Datacenter name in vCenter. Unlike ESXi, vCenter needs the real name"
  type        = string
}

variable "host" {
  description = "The ESXi host as vCenter knows it (its name or IP in the vCenter inventory)"
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
