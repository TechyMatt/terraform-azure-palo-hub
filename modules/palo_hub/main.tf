resource "azurerm_network_watcher" "local" {
  name                = "NetworkWatcher_${local.region_shortcode}"
  resource_group_name = var.resource_groups.networking_resource_group.name
  location            = var.location
  tags                = var.tags.common_tags
}

module "vnet" {
  source              = "./modules/azure_vnet"
  network_definitions = local.networking_definitions
  resource_group_name = var.resource_groups.networking_resource_group.name
  location            = var.location
  vnet_name           = "Hub-vNet-${local.region_shortcode}"
  tags                = var.tags.common_tags

  depends_on = [azurerm_network_watcher.local]
}

output "vnet" {
  value = module.vnet.vnet
}

output "subnets" {
  value = module.vnet.subnets
}

module "palo_inbound" {
  source                  = "./modules/palo_alto_virtual_machine"
  network_details         = module.vnet.subnets
  resource_group_name     = var.resource_groups.paloalto_resource_group.name
  location                = var.location
  tags                    = merge(var.tags.common_tags, var.tags.compute_tags)
  nva_details             = local.networking_definitions["nva_configuration"]["inbound"]
  vm_sku                  = var.palo_vm_sku
  palo_local_user         = var.palo_local_user
  palo_local_password     = var.palo_local_password
  panorama_server_list    = var.panorama_server_list
  management_pip_prefixes = azurerm_public_ip_prefix.management
  deploy_palo_vms = var.deploy_palo_vms
}

module "palo_obew" {
  source                  = "./modules/palo_alto_virtual_machine"
  network_details         = module.vnet.subnets
  resource_group_name     = var.resource_groups.paloalto_resource_group.name
  location                = var.location
  tags                    = merge(var.tags.common_tags, var.tags.compute_tags)
  nva_details             = local.networking_definitions["nva_configuration"]["obew"]
  vm_sku                  = var.palo_vm_sku
  palo_local_user         = var.palo_local_user
  palo_local_password     = var.palo_local_password
  panorama_server_list    = var.panorama_server_list
  production_pip_prefixes = azurerm_public_ip_prefix.production
  management_pip_prefixes = azurerm_public_ip_prefix.management
  deploy_palo_vms = var.deploy_palo_vms
}

//used for provisioning a public IP subnet for inbound and outbound user traffic.
resource "azurerm_public_ip_prefix" "production" {
  name                = "Hub-${local.region_shortcode}-production"
  location            = var.location
  resource_group_name = var.resource_groups.networking_resource_group.name
  availability_zone   = "Zone-Redundant"
  prefix_length       = 28

  tags = var.tags.common_tags
}

//used for provisioning a public IP subnet for the management interfaces of the Palo Altos. By default no IPs will be allocated.
resource "azurerm_public_ip_prefix" "management" {
  name                = "Hub-${local.region_shortcode}-Management"
  location            = var.location
  resource_group_name = var.resource_groups.networking_resource_group.name
  availability_zone   = "Zone-Redundant"
  prefix_length       = 28

  tags = var.tags.common_tags
}

output "management_pip_prefixes" {
  value = azurerm_public_ip_prefix.management
}

module "trust_lb" {
  source                 = "./modules/private_azure_load_balancer"
  name                   = "TrustLB-${local.region_shortcode}"
  network_details        = module.vnet.subnets
  resource_group_name    = var.resource_groups.networking_resource_group.name
  location               = var.location
  tags                   = var.tags.common_tags
  networking_definitions = local.networking_definitions
}

resource "azurerm_network_interface_backend_address_pool_association" "obew" {
  for_each                = module.palo_obew.trust_interfaces
  network_interface_id    = each.value.id
  ip_configuration_name   = "ifconfig0"
  backend_address_pool_id = module.trust_lb.azurelb_be_pool.id

  depends_on = [module.trust_lb, module.palo_inbound]
}

resource "azurerm_route" "trust" {
  name                   = "default_egress"
  route_table_name       = module.vnet.route_tables.trust.name
  resource_group_name    = var.resource_groups.networking_resource_group.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = local.networking_definitions.trust_lb_ip
}

resource "azurerm_route" "untrust" {
  name                = "default_egress"
  route_table_name    = module.vnet.route_tables.untrust.name
  resource_group_name = var.resource_groups.networking_resource_group.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "internet"
}

resource "azurerm_route" "management" {
  name                = "default_egress"
  route_table_name    = module.vnet.route_tables.management.name
  resource_group_name = var.resource_groups.networking_resource_group.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VirtualNetworkGateway"
}

resource "azurerm_route" "gatewaysubnet" {
  for_each               = local.networking_definitions.regional_azure_networks
  name                   = each.key
  route_table_name       = module.vnet.route_tables.gatewaysubnet.name
  resource_group_name    = var.resource_groups.networking_resource_group.name
  address_prefix         = each.value
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = local.networking_definitions.trust_lb_ip
}