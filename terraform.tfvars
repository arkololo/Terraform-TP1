# ============================================================================
# VALEURS DES VARIABLES TERRAFORM
# ============================================================================

# ============================================================================
# Configuration Infrastructure de base
# ============================================================================
project        = "HingeEnjoyer4Living2BetterYourself"
storage_pool   = "local"
remote         = "iaas"
network_name   = "terraform-net"
network_subnet = "10.0.100.1/24"

# ============================================================================
# Configuration VM Ansible
# ============================================================================
ansible_vm_name = "Ansible"
ansible_os_image = "images:ubuntu/24.04/cloud"
ansible_cpu = 1
ansible_memory = "1GB"
ansible_disk = "16GB"
ansible_ip = "10.0.100.10"

# ============================================================================
# Configuration VM Web
# ============================================================================
web_vm_name = "Web"
web_os_image = "debian12-docker"
web_cpu = 1
web_memory = "2GB"
web_disk = "32GB"
web_ip = "10.0.100.20"

# ============================================================================
# SSH & Clés Ansible
# ============================================================================
# Clé privée SSH ED25519 (pour accès Ansible VM)
# ATTENTION: Clé d'exemple - À remplacer par votre clé sécurisée
ansible_ssh_private_key = <<EOF
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACBijjQwTf0qGl4CTRYhM6mn4fiJmAe/66RPsjy+jaRd4gAAAIjJCgV6yQoF
egAAAAtzc2gtZWQyNTUxOQAAACBijjQwTf0qGl4CTRYhM6mn4fiJmAe/66RPsjy+jaRd4g
AAAEAK1YhQhQ2PSJY5NT+SFIQmbs7GPly2zEQq9fz4crgRXWKONDBN/SoaXgJNFiEzqafh
+ImYB7/rpE+yPL6NpF3iAAAAAAECAwQF
-----END OPENSSH PRIVATE KEY-----
EOF

# Clé publique SSH ED25519 (à ajouter dans authorized_keys de Web VM)
# Format OpenSSH : "ssh-ed25519 AAAAC3... user@host"
ansible_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKONDBN/SoaXgJNFiEzqafh+ImYB7/rpE+yPL6NpF3i"

# ============================================================================
# Configuration GitHub & Ansible
# ============================================================================
# URL du dépôt GitHub contenant playbooks et inventory Ansible
github_repo_url = "https://github.com/arkololo/Terraform-TP1.git"
github_repo_branch = "main"

# ============================================================================
# Sécurité & Protection
# ============================================================================
# Protection contre suppression accidentelle (true/false)
# Utile pour la production - true = empêche terraform destroy
security_protection_delete = false

# Autoriser la destruction manuelle des VMs
allow_manual_destroy = true
