variable "resource_group_name" {}

variable "tags" {}

variable "networking_definitions" {}

variable "location" {}

locals {
  vpns = var.networking_definitions[var.location].vpns
}

resource "azurerm_local_network_gateway" "local" {
  for_each            = local.vpns
  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  gateway_address     = each.value.gateway_address
  address_space       = each.value.address_space
}

output "local_network_gateway_config" {
  value = azurerm_local_network_gateway.local
}