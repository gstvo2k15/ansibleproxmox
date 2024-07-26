provider "proxmox" {
  pm_api_url      = "https://192.168.1.250:8006/api2/json"
  pm_user         = "root@pam"
  pm_password     = var.proxmox_password
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "vm" {
  count       = length(var.vm_list)
  name        = var.vm_list[count.index].name
  target_node = "pve"
  clone       = "ubuntu-template"
  cores       = 2
  memory      = 4096
  disk {
    size    = "30G"
    storage = "local-lvm"
  }
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  os_type = "cloud-init"

  ciuser     = "ubuntu"
  cipassword = "ubuntu_password"
  sshkeys    = file("${path.module}/id_rsa.pub")

  provisioner "local-exec" {
    command = "echo ${self.default_ipv4_address} >> ../ansible/inventory/hosts"
  }
}

output "vm_ips" {
  value = [for vm in proxmox_vm_qemu.vm : vm.default_ipv4_address]
}
