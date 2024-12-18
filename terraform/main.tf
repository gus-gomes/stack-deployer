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

  rootfs {
    storage = var.rootfs_storage
    size    = var.rootfs_size
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
  }

  ssh_public_keys = <<-EOT
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJp4R64oi4s9j8+6snX4/8pRsB50V/5RANyLWF/JawbX3p6lpb7Snmurk+PBC4MV8RYOWX00/jZ/eDwqMknMPLjsYkr5NZwmfUvvNIINyLcQ43LExm3f3ndHr1OtFCva0iQrE9WfEn0sqEty6VKEgFCgEsRrJ06kXJPO3bqwXM6kAyS7DIu6Nz+ll6BlkIejJED8ukZXIBa2xmh8j9rr5ndKDMDs/n2qMhQbfBGX94XwEsqFoWOKE1yWXCLMBflZaJTIBx3x2UPeYyBGH1k+NO8OvrJu79NrbLQiLqUqql7UEoo1Bcg5hW9KNEwCeULrirHEfOHyDzZBr9cpdq5CGzojpGdnbM8FTqIYoIQhD4Dst+boc5UeYpoqu4flqogRmJ3Kzi18Zk3uj9eNeybuBJunsxvtDPm5XpxI9whny2IJlLd4rqlNxBCvlHkrjr5Tmzx+WxU6Hl9MN1vE0XlBRDxA15Vukc8Jd8x9F3rWTYBu7vtzCGqi71TRitvJhTzGCRuWbJkC+2KL+mNyvp9bZYBaUSBvlUHgZT9r23+p6PSPsf6jxY7+st+v8Z8ENPnBMGVOnqrKkwYTkMNYMrGl/Utpb/sh0IkqwTj2yX0e/bs9vPJLtXoAr86zgFymeur4WDFHRsDwSxWUmNnZoCM2dclups/Z4FH30IuiquF/IFaQ== gustavogomes@Gustavos-MBP.lan
  EOT

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
  filename = "hosts.yaml"
  content = yamlencode({
    all = {
      hosts = {
        for idx, ip_file in data.local_file.container_ips :
        "lxc-container-${idx + 1}" => {
          ansible_host = chomp(ip_file.content)
        }
      }
    }
  })

  provisioner "local-exec" {
    when = destroy
    command = "rm -f temp_ip_*.txt"
  }
  
}
