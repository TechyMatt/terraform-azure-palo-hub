variable "resource_group_name" {}

variable "tags" {}

variable "networking_definitions" {}

variable "location" {}

variable "subnets" {}

variable "management_pip_prefixes" {}

locals {
  vpns            = var.networking_definitions[var.location].vpns
  vpn_gateway_sku = var.networking_definitions[var.location].vpn_gateway_sku
  vpn_gateway_asn = var.networking_definitions[var.location].vpn_gateway_asn

  region_shortcode = var.networking_definitions[var.location].region_abbreviation
}

resource "azurerm_local_network_gateway" "local" {
  for_each            = local.vpns
  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  gateway_address     = each.value.gateway_address
  address_space       = each.value.address_space
}

output "local_network_gateway_config" {
  value = azurerm_local_network_gateway.local
}

resource "azurerm_public_ip" "local" {
  name                = "${local.region_shortcode}-VPN-Gateway"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_virtual_network_gateway" "local" {
  name                = "${local.region_shortcode}-VPN-Gateway"
  resource_group_name = var.resource_group_name
  location            = var.location

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = true
  sku           = local.vpn_gateway_sku

  bgp_settings {
    asn = local.vpn_gateway_asn
  }

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.local.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.subnets.gatewaysubnet.id
  }

  tags = var.tags
}

resource "azurerm_virtual_network_gateway_connection" "local" {
  for_each            = local.vpns
  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.local.id
  local_network_gateway_id   = azurerm_local_network_gateway.local[each.key].id

  shared_key = each.value.pre_shared_key
}