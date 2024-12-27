output "vm_ips" {
  value = proxmox_vm_qemu.proxmox_vm[*].default_ipv4_address
}