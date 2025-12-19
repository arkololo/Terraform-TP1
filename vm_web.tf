################################################################################
# VM WEB - WORDPRESS & DOCKER
################################################################################

# ============================================================================
# Cloud-init script for Web VM
# ============================================================================
locals {
  # Cloud-init script YAML pour VM Web
  # Actions :
  # 1. Installer openssh-server
  # 2. Ajouter clé publique Ansible dans authorized_keys
  # 3. Configurer SSH pour accepter connexions Ansible
  # 4. Attendre l'exécution du playbook Ansible pour Docker + WordPress

  web_cloud_init = templatefile("${path.module}/cloud-init/web_init.yaml", {
    authorized_keys = local.authorized_keys
  })
}

# ============================================================================
# VM Web Instance
# ============================================================================
resource "incus_instance" "web" {
  name      = var.web_vm_name
  remote    = var.remote
  type      = "virtual-machine"
  project   = var.project
  image     = var.web_os_image
  profiles  = ["default"]

  # Ressources matérielles + Cloud-init
  config = {
    "limits.cpu"                    = tostring(var.web_cpu)
    "limits.memory"                 = var.web_memory
    "security.secureboot"           = "false"
    "cloud-init.user-data"          = local.web_cloud_init
  }

  # Disque root
  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = var.storage_pool
      size = var.web_disk
    }
  }

  # Interface réseau (OVN)
  device {
    name = "eth0"
    type = "nic"
    properties = {
      network        = incus_network.main.name
      "ipv4.address" = var.web_ip
    }
  }

  depends_on = [
    incus_network.main
  ]
}

################################################################################
# Outputs VM Web
################################################################################

output "web_vm_name" {
  description = "Name of Web VM"
  value       = incus_instance.web.name
}

output "web_vm_ip" {
  description = "IPv4 address of Web VM"
  value       = var.web_ip
}

output "web_vm_status" {
  description = "Status of Web VM"
  value       = incus_instance.web.status
}

output "wordpress_url" {
  description = "URL to access WordPress"
  value       = "http://${var.web_ip}:80"
}

output "wordpress_url_admin" {
  description = "URL to access WordPress admin panel"
  value       = "http://${var.web_ip}:80/wp-admin"
}
