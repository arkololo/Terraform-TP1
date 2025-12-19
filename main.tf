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

########################
# OVN NETWORK 
########################
resource "incus_network" "dedicated" {
  name    = "terraform-net"
  remote  = "iaas"
  project = var.project
  type    = "ovn"

  config = {
    # OVN uplink provided by the platform
    "network"      = "UPLINK"

    "ipv4.address" = "10.0.100.1/24"
    "ipv4.nat"     = "true"
    "ipv6.address" = "none"
  }
}

########################
# FRONT VM (ALPINE)
########################
resource "incus_instance" "front" {
  name     = "Front"
  remote   = "iaas"
  type     = "virtual-machine"
  project  = var.project
  image    = "images:alpine/3.20/cloud"
  profiles = ["default"]

  config = {
    "limits.cpu"    = tostring(var.front_cpu)
    "limits.memory" = "512MB"
    "security.secureboot" = "false"
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = var.storage_pool
      size = "16GB"
    }
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network = incus_network.dedicated.name
    }
  }

  depends_on = [incus_network.dedicated]
}

########################
# BACK VM (UBUNTU)
########################
resource "incus_instance" "back" {
  name     = "Back"
  remote   = "iaas"
  type     = "virtual-machine"
  project  = var.project
  image    = "images:ubuntu/jammy/cloud"
  profiles = ["default"]  

  config = {
    "limits.cpu"    = tostring(var.back_cpu)
    "limits.memory" = var.back_memory
    "security.secureboot" = "false"
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = var.storage_pool
      size = "32GB"
    }
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network = incus_network.dedicated.name
    }
  }

  depends_on = [incus_network.dedicated]
}

########################
# OUTPUTS
########################
output "network_name" {
  value = incus_network.dedicated.name
}

output "front_instance" {
  value = incus_instance.front.name
}

output "back_instance" {
  value = incus_instance.back.name
}

########################
# ANSIBLE VM (UBUNTU)
########################
resource "incus_instance" "ansible" {
  name     = "Ansible"
  remote   = "iaas"
  type     = "virtual-machine"
  project  = var.project
  image    = "images:ubuntu/jammy/cloud"
  profiles = ["default"]

  config = {
    "limits.cpu"          = "1"
    "limits.memory"       = "1GB"
    "security.secureboot" = "false"
    "cloud-init.user-data" = file("${path.module}/cloud-init-ansible.yaml")
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = var.storage_pool
      size = "10GB"
    }
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network = incus_network.dedicated.name
    }
  }

  depends_on = [incus_network.dedicated]
}

output "ansible_instance" {
  value = incus_instance.ansible.name
}


 

########################
# DEBIAN 13 PROTECTED VM
########################
resource "incus_instance" "WEB" {
  name     = "WEB"
  remote   = "iaas"
  type     = "virtual-machine"
  project  = var.project
  image    = "images:debian/trixie/cloud"
  profiles = ["default"]

  config = {
    "limits.cpu"                = "1"
    "limits.memory"             = "1GB"
    "security.secureboot"       = "false"
    "security.protection.delete"= "true"
    "user.user-data"            = templatefile(
      "${path.module}/cloud-init-ssh-debian.yaml",
      {
        public_key = var.ansible_ssh_public_key
      }
    )
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = var.storage_pool
      size = "10GB"
    }
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network = incus_network.dedicated.name
    }
  }

  depends_on = [incus_network.dedicated]
}

output "web_instance" {
  value = incus_instance.WEB.name
}
