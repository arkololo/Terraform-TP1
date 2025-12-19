################################################################################
# OPENTOFU OUTPUTS
################################################################################

################################################################################
# Infrastructure Summary
################################################################################

output "infrastructure_summary" {
  description = "Complete infrastructure summary"
  value = {
    network = {
      name   = incus_network.main.name
      subnet = var.network_subnet
    }
    ansible_vm = {
      name   = incus_instance.ansible.name
      ip     = var.ansible_ip
      status = incus_instance.ansible.status
      os     = var.ansible_os_image
    }
    web_vm = {
      name   = incus_instance.web.name
      ip     = var.web_ip
      status = incus_instance.web.status
      os     = var.web_os_image
    }
  }
}

################################################################################
# Access URLs
################################################################################

output "wordpress_access" {
  description = "WordPress URLs and access information"
  value = {
    url            = "http://${var.web_ip}"
    admin_url      = "http://${var.web_ip}/wp-admin"
    phpmyadmin_url = "http://${var.web_ip}:8080"
  }
}

################################################################################
# SSH Access Information
################################################################################

output "ssh_access" {
  description = "SSH access information for VMs"
  value = {
    ansible_vm = "ssh -i ~/.ssh/id_ed25519 ubuntu@${var.ansible_ip}"
    web_vm     = "ssh -i ~/.ssh/id_ed25519 debian@${var.web_ip}"
  }
  sensitive = false
}

################################################################################
# Ansible Execution Status
################################################################################

output "ansible_execution_note" {
  description = "Ansible playbook execution status"
  value       = "Ansible playbook should be executing automatically on Ansible VM. Check logs at /var/log/cloud-init-output.log"
}

################################################################################
# Security Notes
################################################################################

output "security_notes" {
  description = "Important security information"
  value = {
    protection_enabled = var.security_protection_delete
    destruction_allowed = var.allow_manual_destroy
    note               = "Use 'tofu destroy' to remove all resources. If security.protection.delete=true, this will require overriding."
  }
}
