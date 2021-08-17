variable "tags" {}
variable "resource_group_name" {}
variable "location" {}
variable "express_route_definitions" {}
variable "name" {}

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

output "circuit" {
  value = azurerm_express_route_circuit.local
}

output "resource_group_name" {
  value = var.resource_group_name
}