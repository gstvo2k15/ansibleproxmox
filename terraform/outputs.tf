output "vm_ips" {
  value = [for vm in proxmox_vm_qemu.vm : vm.default_ipv4_address]
}
