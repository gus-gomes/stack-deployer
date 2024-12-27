variable "vm_count" {
  default = 3
}

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
  description = "The OS template to use for VM"
  type        = string
}

variable "password" {
  description = "The password for the VM"
  type        = string
}

variable "cores" {
  description = "Number of CPU cores for the VM"
  type        = number
}

variable "memory" {
  description = "Memory size for the VM in MB"
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

variable "sockets" {
  description = "Number of sockets for the VM"
  type        = number
}

variable "user" {
  description = "The user for the VM"
  type        = string  
}

variable "ssh_public_key" {
  description = "The SSH public key"
  type        = string
  
}

