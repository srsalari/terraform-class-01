variable "student" {
  description = "Your ID, used as a prefix for everything you create (e.g. s01). Must be unique if several people share one ESXi host."
  type        = string
}

variable "datastore" {
  description = "Datastore for the VM disk (a fresh ESXi install calls it datastore1)"
  type        = string
  default     = "datastore1"
}

variable "network" {
  description = "Port group the VM connects to"
  type        = string
  default     = "VM Network"
}
