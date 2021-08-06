

resource "azurerm_virtual_network" "local" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  address_space       = var.network_definitions.address_space
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


resource "azurerm_subnet" "trust" {
  name                 = "trust"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.local.name
  address_prefixes     = [var.network_definitions.subnet_trust]
}


resource "azurerm_subnet" "untrust" {
  name                 = "untrust"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.local.name
  address_prefixes     = [var.network_definitions.subnet_untrust]
}


resource "azurerm_subnet" "management" {
  name                 = "management"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.local.name
  address_prefixes     = [var.network_definitions.subnet_management]
  service_endpoints    = ["Microsoft.Storage"]
}

output "subnets" {
  value = {
    "gatewaysubnet" = azurerm_subnet.gatewaysubnet
    "trust"         = azurerm_subnet.trust
    "untrust"       = azurerm_subnet.untrust
    "management"    = azurerm_subnet.management
  }
}

output "vnet" {
  value = azurerm_virtual_network.local
}
