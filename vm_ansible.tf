################################################################################
# VM ANSIBLE - ORCHESTRATION NODE
################################################################################

# ============================================================================
# Cloud-init script for Ansible VM
# ============================================================================
locals {
  # Cloud-init script YAML
  # Actions automatiques au démarrage :
  # 1. Installer openssh-server, git, ansible
  # 2. Générer clé SSH ED25519
  # 3. Configurer authorized_keys
  # 4. Cloner le repo GitHub avec playbooks
  # 5. Lancer automatiquement ansible-playbook

  ansible_cloud_init = templatefile("${path.module}/cloud-init/ansible_init.yaml", {
    web_ip               = var.web_ip
    github_repo_url      = var.github_repo_url
    github_repo_branch   = var.github_repo_branch
    authorized_keys      = local.authorized_keys
  })
}

# ============================================================================
# VM Ansible Instance
# ============================================================================
resource "incus_instance" "ansible" {
  name      = var.ansible_vm_name
  remote    = var.remote
  type      = "virtual-machine"
  project   = var.project
  image     = var.ansible_os_image
  profiles  = ["default"]

  # Ressources matérielles + Cloud-init
  config = {
    "limits.cpu"                    = tostring(var.ansible_cpu)
    "limits.memory"                 = var.ansible_memory
    "security.secureboot"           = "false"
    "cloud-init.user-data"          = local.ansible_cloud_init
  }

  # Disque root
  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = var.storage_pool
      size = var.ansible_disk
    }
  }

  # Interface réseau (OVN)
  device {
    name = "eth0"
    type = "nic"
    properties = {
      network = incus_network.main.name
    }
  }

  depends_on = [
    incus_network.main
  ]
}

################################################################################
# Outputs VM Ansible
################################################################################

output "ansible_vm_name" {
  description = "Name of Ansible VM"
  value       = incus_instance.ansible.name
}

output "ansible_vm_ip" {
  description = "IPv4 address of Ansible VM"
  value       = var.ansible_ip
}

output "ansible_vm_status" {
  description = "Status of Ansible VM"
  value       = incus_instance.ansible.status
}
