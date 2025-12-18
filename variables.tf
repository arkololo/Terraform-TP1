variable "project" {
  description = "Incus project to use"
  type        = string
  default     = "HingeEnjoyer4Living2BetterYourself"
}

variable "storage_pool" {
  description = "Storage pool for VMs"
  type        = string
  default     = "local"
}

# Front VM variables
variable "front_cpu" {
  description = "Number of CPU cores for Front VM"
  type        = number
  default     = 1
}

# Back VM variables
variable "back_cpu" {
  description = "Number of CPU cores for Back VM"
  type        = number
  default     = 1
}

variable "back_memory" {
  description = "Memory for Back VM (e.g., 1GB, 1024MB)"
  type        = string
  default     = "1GB"
}

# Load balancer toggle
variable "enable_lb" {
  description = "Whether to create the load balancer forward"
  type        = bool
  default     = false
}

# User-provided SSH keypair for Ansible ↔ WEB
variable "ansible_ssh_private_key" {
  description = "Private key (PEM) to install on Ansible VM"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ansible_ssh_public_key" {
  description = "Public key (OpenSSH format) to authorize on WEB VM"
  type        = string
  sensitive   = true
  default     = ""
}
