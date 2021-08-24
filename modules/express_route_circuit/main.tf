variable "tags" {}
variable "resource_group_name" {}
variable "location" {}
variable "express_route_definitions" {}
variable "name" {}
variable "configure_er_private_peering" {}

resource "azurerm_express_route_circuit" "local" {
  name                  = var.name
  resource_group_name   = var.resource_group_name
  location              = var.location
  service_provider_name = var.express_route_definitions.service_provider_name
  peering_location      = var.express_route_definitions.peering_location
  bandwidth_in_mbps     = var.express_route_definitions.bandwidth_in_mbps

  sku {
    tier   = var.express_route_definitions.tier
    family = var.express_route_definitions.family
  }

  allow_classic_operations = false

  tags = var.tags
}

resource "azurerm_express_route_circuit_peering" "local" {
  count                         = var.configure_er_private_peering ? 1 : 0
  peering_type                  = "AzurePrivatePeering"
  express_route_circuit_name    = azurerm_express_route_circuit.local.name
  resource_group_name           = var.resource_group_name
  peer_asn                      = var.express_route_definitions.azure_private_peering.peer_asn
  primary_peer_address_prefix   = var.express_route_definitions.azure_private_peering.ipv4_primary_subnet
  secondary_peer_address_prefix = var.express_route_definitions.azure_private_peering.ipv4_secondary_subnet
  vlan_id                       = var.express_route_definitions.azure_private_peering.vlan_id
  shared_key                    = var.express_route_definitions.azure_private_peering.shared_key != "" ? var.express_route_definitions.azure_private_peering.shared_key : null
}

output "circuit" {
  value = azurerm_express_route_circuit.local
}

output "resource_group_name" {
  value = var.resource_group_name
}