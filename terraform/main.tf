terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }
}


resource "proxmox_vm_qemu" "resource-name" {
  name        = "VM-name"
  target_node = "proxmox"

  disks {
    ide {
      ide2 {
        cdrom {
          iso = "ubuntu-24.04-live-server-amd64.iso"
        }
      }
    }
  }

  ### or for a Clone VM operation
  # clone = "template to clone"

  ### or for a PXE boot VM operation
  # pxe = true
  # boot = "scsi0;net0"
  # agent = 0
  memory = 2048
}
