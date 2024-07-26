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
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "template" {
  count       = 1
  name        = "ubuntu-template"
  target_node = "pve"
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
  clone    = "base-template" # Assume you have a base template
  ciuser   = "ubuntu"
  cipassword = "ubuntu_password"
  sshkeys  = file("/root/ansibleproxmox/terraform/id_rsa.pub")
}

resource "null_resource" "convert_to_template" {
  provisioner "local-exec" {
    command = "pvesh set /nodes/pve/qemu/${proxmox_vm_qemu.template.0.id}/template"
  }
  depends_on = [proxmox_vm_qemu.template]
}

resource "proxmox_vm_qemu" "vm" {
  count       = length(var.vm_list)
  name        = var.vm_list[count.index].name
  target_node = "pve"
  clone       = proxmox_vm_qemu.template[0].name
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