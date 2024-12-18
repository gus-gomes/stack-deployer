variable "pm_api_url" {
  description = "The API URL for Proxmox"
  type        = string
}

variable "pm_api_token_id" {
  description = "The API token ID for Proxmox"
  type        = string
}

variable "pm_api_token_secret" {
  description = "The API token secret for Proxmox"
  type        = string
}

variable "target_node" {
  description = "The target node in Proxmox"
  type        = string
}

variable "ostemplate" {
  description = "The OS template to use for LXC containers"
  type        = string
}

variable "container_password" {
  description = "The password for the LXC container"
  type        = string
}

variable "cores" {
  description = "Number of CPU cores for the container"
  type        = number
}

variable "memory" {
  description = "Memory size for the container in MB"
  type        = number
}

variable "rootfs_storage" {
  description = "Storage for the root filesystem"
  type        = string
}

variable "rootfs_size" {
  description = "Size of the root filesystem"
  type        = string
}

variable "proxmox_host" {
  description = "The Proxmox host IP or hostname"
  type        = string
}
