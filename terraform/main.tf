terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9.7"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://192.168.1.250:8006/api2/json"
  pm_user         = "root@pam"
  pm_password     = var.proxmox_password
  pm_tls_insecure = true  # Deshabilita la verificación del certificado SSL
}

resource "proxmox_vm_qemu" "base" {
  name        = "ubuntu-base"
  target_node = 192.168.1.250
  vmid        = 700  # ID for the base VM
  cores       = 2
  memory      = 4096
  disk {
    size    = "30G"
    storage = "local-lvm"
    type    = "scsi"
  }
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  iso = "local:iso/ubuntu-22.04.iso"
  os_type = "cloud-init"
}

resource "null_resource" "convert_to_template" {
  provisioner "local-exec" {
    command = "pvesh set /nodes/${var.proxmox_node_ip}/qemu/${proxmox_vm_qemu.base.id}/template"
  }
  depends_on = [proxmox_vm_qemu.base]
}

resource "proxmox_vm_qemu" "vm" {
  count       = length(var.vm_list)
  name        = var.vm_list[count.index].name
  target_node = var.proxmox_node_ip
  vmid        = 701 + count.index  # Start VM IDs from 701
  clone       = "ubuntu-base"
  cores       = 2
  memory      = 4096
  disk {
    size    = "30G"
    storage = "local-lvm"
    type    = "scsi"
  }
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  os_type = "cloud-init"
  ciuser     = "ubuntu"
  cipassword = "ubuntu_password"
}

output "vm_ips" {
  value = [for vm in proxmox_vm_qemu.vm : vm.default_ipv4_address]
}
