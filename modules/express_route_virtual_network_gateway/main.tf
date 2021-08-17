variable "location" {}
variable "resource_group_name" {}
variable "subnets" {}
variable "management_pip_prefixes" {}
variable "networking_definitions" {}
variable "tags" {}
variable "express_route_circuits" {}
variable "connect_er_circuits_to_gateway" {}

locals {
  express_route_gateway_sku = var.networking_definitions[var.location].express_route_gateway_sku
  express_route_connections = var.networking_definitions[var.location].express_route_connections
  //express_route_circuits = flatten(var.express_route_circuits)
  region_shortcode = var.networking_definitions[var.location].region_abbreviation
}

resource "azurerm_public_ip" "express_route" {
  name                = "${local.region_shortcode}-expressroute-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_virtual_network_gateway" "express_route" {
  name                = "${local.region_shortcode}-expressroute-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name

  type = "ExpressRoute"

  sku = local.express_route_gateway_sku

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.express_route.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.subnets.gatewaysubnet.id
  }
  tags = var.tags
}

resource "azurerm_express_route_circuit_authorization" "local" {
  for_each                   = toset(local.express_route_connections)
  name                       = "${each.key}-${local.region_shortcode}-Auth"
  express_route_circuit_name = each.key
  resource_group_name        = var.express_route_circuits[each.key].resource_group_name
}


resource "azurerm_virtual_network_gateway_connection" "local" {

  for_each            = { for k, v in toset(local.express_route_connections) : k => v if var.connect_er_circuits_to_gateway }
  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location

  type                       = "ExpressRoute"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.express_route.id
  authorization_key          = azurerm_express_route_circuit_authorization.local[each.key].authorization_key
  express_route_circuit_id   = var.express_route_circuits[each.key].circuit.id

}
