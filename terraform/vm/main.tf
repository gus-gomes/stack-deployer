provider "proxmox" {
  pm_api_url = var.pm_api_url
  pm_api_token_id = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "proxmox_vm" {
  count = var.vm_count  # Number of VMs to create
  name = "vm-${count.index + 1}"
  target_node = var.target_node
  clone = var.ostemplate
  agent = 1
  
  # VM configuration
  cores = var.cores
  sockets = var.sockets
  memory = var.memory

  scsihw = "virtio-scsi-single"
  
  # Cloud-init settings
  os_type = "cloud-init"
  ipconfig0 = "ip=dhcp"

  ciuser = var.user
  cipassword = var.password

  sshkeys = var.ssh_public_key
  
  # Disk configuration
  disk {
    slot = "scsi0"
    type = "disk"
    storage = var.rootfs_storage
    size = var.rootfs_size
    discard = true
    emulatessd = true
  }

  disk {
    slot = "ide0"
    type = "cloudinit"
    storage = var.rootfs_storage
    size = "4M"
  }
  
  disk {
    slot = "ide2"
    type = "cdrom" 
  }

  serial {
    type = "socket"
    id = 0
  }

  vga {
    type = "serial0"
  }
  
  # Network configuration
  network {
    id = 0
    model = "virtio"
    bridge = "vmbr0"
  }
}

resource "local_file" "ansible_inventory" {
  content = yamlencode({
    controllers = {
      hosts = {
        for vm in proxmox_vm_qemu.proxmox_vm : vm.name => {
          ansible_host = vm.default_ipv4_address
          ansible_user = var.user
        }
      } 
    }
  })
  filename = "hosts.yaml"
}

