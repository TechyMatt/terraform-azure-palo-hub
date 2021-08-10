variable "tags" {}
variable "resource_group_name" {}
variable "location" {}
variable "networking_definitions" {}

resource "azurerm_express_route_circuit" "local" {
  for_each              = var.networking_definitions[var.location].express_routes
  name                  = each.value.name
  resource_group_name   = var.resource_group_name
  location              = var.location
  service_provider_name = each.value.service_provider_name
  peering_location      = each.value.peering_location
  bandwidth_in_mbps     = each.value.bandwidth_in_mbps

  sku {
    tier   = each.value.tier
    family = each.value.family
  }

  allow_classic_operations = false

  tags = var.tags
}

resource "azurerm_express_route_circuit_authorization" "local" {
  for_each                   = var.networking_definitions[var.location].express_routes
  name                       = "${each.value.name}-Auth"
  express_route_circuit_name = azurerm_express_route_circuit.local[each.key].name
  resource_group_name        = var.resource_group_name
}