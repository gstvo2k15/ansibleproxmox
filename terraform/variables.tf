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
  default     = "proxmoxnode"
}

variable "proxmox_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  default     = "a201470b-de94-4659-bffe-bdaea73ef927"
}