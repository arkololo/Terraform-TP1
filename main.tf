terraform {
  required_version = ">= 1.6.0"

  required_providers {
    incus = {
      source  = "lxc/incus"
      version = ">= 1.0.0"
    }
  }
}

provider "incus" {
  config_dir     = "${pathexpand("~")}/.config/incus"
  default_remote = "iaas"
}

locals {
  # Format: "ssh-ed25519 AAAA... user@host"
  # Utilisé pour autoriser l'accès Ansible → Web
  authorized_keys = "${var.ansible_ssh_public_key}\n"
}
