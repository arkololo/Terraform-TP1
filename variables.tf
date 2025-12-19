################################################################################
# VARIABLES TERRAFORM
################################################################################

# ============================================================================
# Infrastructure de base
# ============================================================================

variable "project" {
  description = "Incus project name"
  type        = string
  default     = "HingeEnjoyer4Living2BetterYourself"
}

variable "storage_pool" {
  description = "Storage pool for VMs"
  type        = string
  default     = "local"
}

variable "remote" {
  description = "Incus remote name"
  type        = string
  default     = "iaas"
}

variable "network_name" {
  description = "Name of OVN network to create"
  type        = string
  default     = "terraform-net"
}

variable "network_subnet" {
  description = "Network subnet for VMs (IPv4 only)"
  type        = string
  default     = "10.0.100.1/24"
}

# ============================================================================
# VM Ansible Configuration
# ============================================================================

variable "ansible_vm_name" {
  description = "Name of the Ansible VM"
  type        = string
  default     = "Ansible"
}

variable "ansible_os_image" {
  description = "Cloud image for Ansible VM (Ubuntu 24.04)"
  type        = string
  default     = "images:ubuntu/24.04/cloud"
}

variable "ansible_cpu" {
  description = "Number of CPU cores for Ansible VM"
  type        = number
  default     = 1
}

variable "ansible_memory" {
  description = "Memory for Ansible VM"
  type        = string
  default     = "1GB"
}

variable "ansible_disk" {
  description = "Disk size for Ansible VM"
  type        = string
  default     = "16GB"
}

variable "ansible_ip" {
  description = "Static IPv4 address for Ansible VM"
  type        = string
  default     = "10.0.100.10"
}

# ============================================================================
# VM Web Configuration
# ============================================================================

variable "web_vm_name" {
  description = "Name of the Web VM"
  type        = string
  default     = "Web"
}

variable "web_os_image" {
  description = "Cloud image for Web VM (Debian 12)"
  type        = string
  default     = "images:debian/12/cloud"
}

variable "web_cpu" {
  description = "Number of CPU cores for Web VM"
  type        = number
  default     = 1
}

variable "web_memory" {
  description = "Memory for Web VM"
  type        = string
  default     = "2GB"
}

variable "web_disk" {
  description = "Disk size for Web VM"
  type        = string
  default     = "32GB"
}

variable "web_ip" {
  description = "Static IPv4 address for Web VM"
  type        = string
  default     = "10.0.100.20"
}

# ============================================================================
# SSH & Ansible Configuration
# ============================================================================

variable "ansible_ssh_private_key" {
  description = "Private SSH key (ED25519 PEM format) for Ansible VM"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ansible_ssh_public_key" {
  description = "Public SSH key (OpenSSH format) to authorize on Web VM"
  type        = string
  default     = ""
}

variable "github_repo_url" {
  description = "GitHub repository URL containing Ansible playbooks and inventory"
  type        = string
  default     = "https://github.com/arkololo/ansible-wordpress.git"
}

variable "github_repo_branch" {
  description = "GitHub repository branch to clone"
  type        = string
  default     = "main"
}

# ============================================================================
# Security & Protection
# ============================================================================

variable "security_protection_delete" {
  description = "Whether to protect resources from deletion (true/false). Set to true for production."
  type        = bool
  default     = false
}

variable "allow_manual_destroy" {
  description = "Allow manual destruction of VMs (requires explicit confirmation)"
  type        = bool
  default     = true
}
