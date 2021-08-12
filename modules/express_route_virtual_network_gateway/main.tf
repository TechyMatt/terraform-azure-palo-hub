variable "location" {}
variable "resource_group_name" {}
variable "subnets" {}
variable "management_pip_prefixes" {}
variable "networking_definitions" {}
variable "tags" {}
variable "express_route_circuits" {}

locals {
  express_routes            = var.networking_definitions[var.location].express_routes
  express_route_gateway_sku = var.networking_definitions[var.location].express_route_gateway_sku

  region_shortcode = var.networking_definitions[var.location].region_abbreviation
}

/*
locals {
 express_route_circuits = flatten([
    for role, scopes in var.role_assignments : [
      for scope in scopes : {
        role  = role
        scope = scope
      }
    ]
  ])
}
*/

resource "azurerm_public_ip" "express_route" {
  name                = "${local.region_shortcode}-expressroute-pip"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Dynamic"
  tags              = var.tags
}

resource "azurerm_virtual_network_gateway" "express_route" {
  name                = "${local.region_shortcode}-expressroute-gateway"
  location            = var.location
  resource_group_name = var.resource_group_name

  type = "ExpressRoute"

  enable_bgp = true

  sku = local.express_route_gateway_sku

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.express_route.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.subnets.gatewaysubnet.id
  }
  tags = var.tags
}

/*
resource "azurerm_virtual_network_gateway_connection" "local" {
  for_each = {
    for name, user in var.express_route_circuits : name => user
    if user.ssh_public_key != ""
  }
  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location

  type                       = "ExpressRoute"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.local.id
  authorization_key = 
  express_route_circuit_id

  shared_key = each.value.pre_shared_key
}
*/