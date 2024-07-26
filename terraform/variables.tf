variable "vm_list" {
  description = "List of VMs to create"
  type        = list(object({
    id   = number
    name = string
  }))
  default = []
}

variable "proxmox_password" {
  description = "Proxmox password"
  type        = string
}