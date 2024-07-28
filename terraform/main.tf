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
  pm_tls_insecure    = true
  pm_debug           = true
}

resource "proxmox_vm_qemu" "vm" {
  count       = length(var.vm_list)
  name        = var.vm_list[count.index].name
  target_node = var.proxmox_node_ip
  vmid        = var.vm_list[count.index].id  # Usar el id especificado
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
  iso = "local:iso/ubuntu-22.04.4-live-server-amd64.iso"
  os_type = "cloud-init"
  onboot = true
  provisioner "local-exec" {
    command = "sleep 60 && echo ${self.default_ipv4_address} >> ../ansible/inventory/hosts"
  }
  additional_wait = 30
  clone_wait = 30
  guest_agent_ready_timeout = 120  
}

output "vm_ips" {
  value = [for vm in proxmox_vm_qemu.vm : vm.default_ipv4_address]
}
