

resource "azurerm_virtual_network" "local" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  address_space       = var.network_definitions.hub_vnet_address_space
  location            = var.location
  dns_servers         = var.network_definitions.dns_servers

  tags = var.tags
}



resource "azurerm_subnet" "gatewaysubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.local.name
  address_prefixes     = [var.network_definitions.gatewaysubnet]
}

resource "azurerm_route_table" "gatewaysubnet" {
  name                = "GatewaySubnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_route_table_association" "gatewaysubnet" {
  subnet_id      = azurerm_subnet.gatewaysubnet.id
  route_table_id = azurerm_route_table.gatewaysubnet.id
}

resource "azurerm_subnet" "trust" {
  name                 = "trust"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.local.name
  address_prefixes     = [var.network_definitions.subnet_trust]
}

resource "azurerm_route_table" "trust" {
  name                          = "trust"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = true
  tags                          = var.tags
}

resource "azurerm_subnet_route_table_association" "trust" {
  subnet_id      = azurerm_subnet.trust.id
  route_table_id = azurerm_route_table.trust.id
}


resource "azurerm_subnet" "untrust" {
  name                 = "untrust"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.local.name
  address_prefixes     = [var.network_definitions.subnet_untrust]
}

resource "azurerm_route_table" "untrust" {
  name                          = "untrust"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = true
  tags                          = var.tags
}

resource "azurerm_subnet_route_table_association" "untrust" {
  subnet_id      = azurerm_subnet.untrust.id
  route_table_id = azurerm_route_table.untrust.id
}


resource "azurerm_subnet" "management" {
  name                 = "management"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.local.name
  address_prefixes     = [var.network_definitions.subnet_management]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_route_table" "management" {
  name                = "management"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_route_table_association" "management" {
  subnet_id      = azurerm_subnet.management.id
  route_table_id = azurerm_route_table.management.id
}

output "subnets" {
  value = {
    "gatewaysubnet" = azurerm_subnet.gatewaysubnet
    "trust"         = azurerm_subnet.trust
    "untrust"       = azurerm_subnet.untrust
    "management"    = azurerm_subnet.management
  }
}

output "route_tables" {
  value = {
    "gatewaysubnet" = azurerm_route_table.gatewaysubnet
    "trust"         = azurerm_route_table.trust
    "untrust"       = azurerm_route_table.untrust
    "management"    = azurerm_route_table.management
  }
}

output "vnet" {
  value = azurerm_virtual_network.local
}
