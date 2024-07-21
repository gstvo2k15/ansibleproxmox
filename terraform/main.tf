provider "proxmox" {
  pm_api_url = var.pm_api_url
  pm_user    = var.pm_user
  pm_password = var.pm_password
  pm_tls_insecure = true
}

locals {
  iso_image = lookup(
    {
      "ubuntu22" = "local:iso/ubuntu-22.04.4-live-server-amd64.iso"
      "rocky9"   = "local:iso/Rocky-9.3-x86_64-minimal.iso"
    },
    var.os_image,
    "local:iso/ubuntu-22.04.4-live-server-amd64.iso"  # Valor predeterminado si no se encuentra ninguna coincidencia
  )
}

resource "proxmox_vm_qemu" "vm" {
  count = 1
  name  = var.vm_name
  target_node = var.target_node
  iso = local.iso_image
  storage = var.storage
  cores = var.vm_cores
  sockets = 1
  memory = var.vm_memory
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"
  disk {
    size = var.vm_disk_size
    type = "scsi"
    storage = var.storage
  }
  network {
    model = "virtio"
    bridge = var.network_bridge
    ipconfig0 = "ip=${var.vm_ip},gw=${var.gateway}"
  }
  clone = var.clone_template
  sshkeys = file(var.ssh_key_path)
}

variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "pm_user" {
  description = "Proxmox user"
  type        = string
}

variable "pm_password" {
  description = "Proxmox password"
  type        = string
  sensitive   = true
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "target_node" {
  description = "Proxmox target node"
  type        = string
}

variable "storage" {
  description = "Storage location"
  type        = string
}

variable "vm_cores" {
  description = "Number of CPU cores for the VM"
  type        = number
}

variable "vm_memory" {
  description = "Amount of RAM for the VM in MB"
  type        = number
}

variable "vm_disk_size" {
  description = "Disk size for the VM"
  type        = string
}

variable "network_bridge" {
  description = "Network bridge to use"
  type        = string
}

variable "gateway" {
  description = "Network gateway"
  type        = string
}

variable "clone_template" {
  description = "Template to clone"
  type        = string
}

variable "ssh_key_path" {
  description = "Path to SSH public key"
  type        = string
}

variable "vm_ip" {
  description = "IP address for the VM"
  type        = string
}

variable "os_image" {
  description = "Operating system image to use"
  type        = string
}
