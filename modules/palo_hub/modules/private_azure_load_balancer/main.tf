resource "azurerm_lb" "local" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "primary"
    availability_zone             = "Zone-Redundant"
    subnet_id                     = var.network_details.trust.id
    private_ip_address            = var.networking_definitions.trust_lb_ip
    private_ip_address_version    = "IPv4"
    private_ip_address_allocation = "Static"
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "local" {
  loadbalancer_id = azurerm_lb.local.id
  name            = "PaloAltoNVAs"
}

//azurerm_lb_backend_address_pool_address configured in parent module

resource "azurerm_lb_rule" "local" {
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

resource "azurerm_lb_probe" "local" {
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.local.id
  name                = "ssh-probe"
  port                = 22
}

output "azurelb_trust" {
  value = azurerm_lb.local
}

output "azurelb_be_pool" {
  value = azurerm_lb_backend_address_pool.local
}