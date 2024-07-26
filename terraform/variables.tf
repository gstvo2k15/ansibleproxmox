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

variable "proxmox_node_ip" {
  description = "IP address of the Proxmox node"
  type        = string
  default     = "192.168.1.250"
}

