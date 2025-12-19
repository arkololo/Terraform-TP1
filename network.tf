################################################################################
# NETWORK CONFIGURATION
################################################################################

# ============================================================================
# OVN Network - Main
# ============================================================================
resource "incus_network" "main" {
  name    = var.network_name
  remote  = var.remote
  project = var.project
  type    = "ovn"

  config = {
    # OVN uplink fourni par la plateforme
    "network"      = "UPLINK"

    # IPv4 configuration
    "ipv4.address" = var.network_subnet
    "ipv4.nat"     = "true"

    # IPv6 DISABLED (contrainte : IPv4 uniquement)
    "ipv6.address" = "none"
  }

  depends_on = []
}

################################################################################
# Outputs Network
################################################################################

output "network_name" {
  description = "Name of the created OVN network"
  value       = incus_network.main.name
}

output "network_subnet" {
  description = "Network subnet (CIDR)"
  value       = var.network_subnet
}
