## Exposed
## Fix: https://medium.com/@magelan09/terraform-encrypted-variables-how-not-to-commit-sensitive-information-to-a-git-58d51e462e1a
provider "proxmox" {
 pm_api_url   = "https://192.168.1.213:8006/api2/json"
 pm_api_token_id      = "terraform-prov@pve!infra"
 pm_api_token_secret  = "1a2c9c64-1be1-4c29-aecc-3a3f6270518e"
 pm_tls_insecure = true
}
