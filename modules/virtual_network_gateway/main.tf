variable "location_shortcode" {}
variable "location" {}
variable "resource_group_name" {}
variable "gateway_subnet" {}

resource "azurerm_public_ip" "express_route" {
  name                = "${var.location_shortcode}-expressroute-pip"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "example" {
  name                = "${var.location_shortcode}-expressroute-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name

  type     = "ExpressRoute"

  enable_bgp    = false

  sku           = "Basic"

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.express_route.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet.id
  }
}