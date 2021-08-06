variable "tags" {}
variable "location" {}
variable "location_shortcode" {}

locals {

  resource_groups = {
    networking   = "Hub-Networking-${var.location_shortcode}"
    expressroute = "Hub-ExpressRoute-${var.location_shortcode}"
    palo         = "Hub-PaloAlto-${var.location_shortcode}"
    vpn          = "Hub-VPN-${var.location_shortcode}"
  }

}

resource "azurerm_resource_group" "express_route" {
  name     = local.resource_groups.expressroute
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "networking" {
  name     = local.resource_groups.networking
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "paloalto" {
  name     = local.resource_groups.palo
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "vpn" {
  name     = local.resource_groups.vpn
  location = var.location
  tags     = var.tags
}

output "combined" {
  value = {
    "express_route_resource_group" = azurerm_resource_group.express_route
    "networking_resource_group"    = azurerm_resource_group.networking
    "paloalto_resource_group"      = azurerm_resource_group.paloalto
    "vpn_resource_group"           = azurerm_resource_group.vpn
  }
}