terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }
}

## Exposed
## Fix: https://medium.com/@magelan09/terraform-encrypted-variables-how-not-to-commit-sensitive-information-to-a-git-58d51e462e1a
provider "proxmox" {
 pm_api_url   = "https://<ip-addr>:8006/api2/json"
 pm_api_token_id      = "terraform-prov@pve!infra"
 pm_api_token_secret  = ""
 pm_tls_insecure = true
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
