variable "tags" {}
variable "network_details" {}
variable "resource_group_name" {}
variable "location" {}
variable "networking_definitions" {}
variable "name" {}
variable "public_ip_prefix" {}

resource "azurerm_public_ip" "local" {
  for_each            = var.networking_definitions.inbound_load_balancer_ports
  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  public_ip_prefix_id = var.public_ip_prefix
}

resource "azurerm_lb" "local" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  dynamic "frontend_ip_configuration" {
    for_each = var.networking_definitions.inbound_load_balancer_ports

    content {
      name                 = frontend_ip_configuration.key
      public_ip_address_id = azurerm_public_ip.local[frontend_ip_configuration.key].id
    }
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "local" {
  for_each        = var.networking_definitions.inbound_load_balancer_ports
  loadbalancer_id = azurerm_lb.local.id
  name            = each.key
}

resource "azurerm_lb_probe" "local" {
  for_each            = var.networking_definitions.inbound_load_balancer_ports
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.local.id
  name                = "${each.key}-probe"
  port                = each.value.probe
}

/*

resource "azurerm_network_interface_backend_address_pool_association" "local" {
  for_each                = module.palo_obew.trust_interfaces
  network_interface_id    = each.value.id
  ip_configuration_name   = "ifconfig0"
  backend_address_pool_id = module.trust_lb.azurelb_be_pool.id
}

*/
/*
resource "azurerm_lb_rule" "local" {
  for_each = var.networking_definitions.inbound_ports
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.local.id
  name                           = "AllTraffic"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "primary"
  enable_floating_ip             = "true"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.local.id
  probe_id                       = azurerm_lb_probe.local.id
}

output "azurelb_trust" {
  value = azurerm_lb.local
}

output "azurelb_be_pool" {
  value = azurerm_lb_backend_address_pool.local
}
*/
