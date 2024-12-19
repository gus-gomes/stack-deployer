provider "proxmox" {
  pm_api_url = var.pm_api_url
  pm_api_token_id = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure = true
}

resource "proxmox_lxc" "lxc_container" {
  count       = 3
  vmid        = 102 + count.index
  target_node = var.target_node
  hostname    = "ubuntu-lxc-${count.index + 1}"
  ostemplate  = var.ostemplate
  password    = var.container_password
  unprivileged = true
  start       = true

  cores  = var.cores
  memory = var.memory
  swap   = 1024
  
  ssh_public_keys = [var.ssh_public_key]
  rootfs {
    storage = var.rootfs_storage
    size    = var.rootfs_size
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
  }

}

resource "null_resource" "fetch_ips" {
  count = 3

  depends_on = [proxmox_lxc.lxc_container]

  provisioner "local-exec" {
    command = <<-EOT
      TIMEOUT=60  # Set timeout in seconds
      INTERVAL=5   # Set interval between checks
      ELAPSED=0

      while [ $ELAPSED -lt $TIMEOUT ]; do
        IP=$(ssh -o StrictHostKeyChecking=no root@${var.proxmox_host} "pct exec ${proxmox_lxc.lxc_container[count.index].vmid} -- ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'")
        
        if [ ! -z "$IP" ]; then
          echo "$IP" > temp_ip_${count.index}.txt
          break
        fi
        
        sleep $INTERVAL
        ELAPSED=$((ELAPSED + INTERVAL))
      done

      if [ $ELAPSED -ge $TIMEOUT ]; then
        echo "Timeout reached while waiting for IP address of container ${proxmox_lxc.lxc_container[count.index].vmid}" >&2
        exit 1
      fi
    EOT
  }

}

data "local_file" "container_ips" {
  count = 3
  filename = "${path.module}/temp_ip_${count.index}.txt"
  depends_on = [null_resource.fetch_ips]
}

resource "local_file" "hosts_yaml" {
  filename = "../hosts.yaml"
  content = yamlencode({
    controllers = {
      hosts = {
        for idx, ip_file in data.local_file.container_ips :
        "lxc-container-${idx + 1}" => {
          ansible_host = chomp(ip_file.content)
          ansible_connection: "ssh"
          ansible_user: "root"
        }
      }
    }
  })

  provisioner "local-exec" {
    when = destroy
    command = "rm -f temp_ip_*.txt"
  }
  
}
