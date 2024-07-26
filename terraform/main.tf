terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9.7"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://${var.proxmox_node_ip}:8006/api2/json"
  pm_user         = "root@pam"
  pm_password     = var.proxmox_password  
  #pm_api_token_id     = "root@pam!asdasdas"
  #pm_api_token_secret = var.proxmox_token_secret
  pm_tls_insecure    = true
  pm_debug           = true
}

resource "proxmox_vm_qemu" "base" {
  name        = "ubuntu-base"
  target_node = var.proxmox_node_ip
  vmid        = 700
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
  vmid        = 701 + count.index
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
  sshkeys    = file("/root/.ssh/id_rsa.pub")
  provisioner "local-exec" {
    command = "echo ${self.default_ipv4_address} >> ../ansible/inventory/hosts"
  }
}

output "vm_ips" {
  value = [for vm in proxmox_vm_qemu.vm : vm.default_ipv4_address]
}
