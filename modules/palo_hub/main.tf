resource "azurerm_network_watcher" "local" {
  name                = "NetworkWatcher_${var.region_shortcode}"
  resource_group_name = var.resource_groups.networking_resource_group.name
  location            = var.location
  tags                = var.common_tags
}

module "vnet" {
  source              = "./modules/azure_vnet"
  network_definitions = var.networking_definitions
  resource_group_name = var.resource_groups.networking_resource_group.name
  location            = var.location
  vnet_name           = "Hub-vNet-${var.region_shortcode}"
  tags                = var.common_tags

  depends_on = [azurerm_network_watcher.local]
}

output "vnet" {
  value = module.vnet.vnet
}

output "subnets" {
  value = module.vnet.subnets
}

module "palo_inbound" {
  source               = "./modules/palo_alto_virtual_machine"
  network_details      = module.vnet.subnets
  resource_group_name  = var.resource_groups.paloalto_resource_group.name
  location             = var.location
  tags                 = var.common_tags
  nva_details          = var.networking_definitions["nva_configuration"]["inbound"]
  vm_sku               = var.palo_vm_sku
  palo_local_user      = var.palo_local_user
  palo_local_password  = var.palo_local_password
  panorama_server_list = var.panorama_server_list
}

module "palo_obew" {
  source               = "./modules/palo_alto_virtual_machine"
  network_details      = module.vnet.subnets
  resource_group_name  = var.resource_groups.paloalto_resource_group.name
  location             = var.location
  tags                 = var.common_tags
  nva_details          = var.networking_definitions["nva_configuration"]["obew"]
  vm_sku               = var.palo_vm_sku
  palo_local_user      = var.palo_local_user
  palo_local_password  = var.palo_local_password
  panorama_server_list = var.panorama_server_list
}

resource "azurerm_public_ip_prefix" "region" {
  name                = "Hub-${var.region_shortcode}-Prefixes"
  location            = var.location
  resource_group_name = var.resource_groups.networking_resource_group.name
  availability_zone   = "Zone-Redundant"
  prefix_length       = 28

  tags = var.common_tags
}

module "trust_lb" {
  source                 = "./modules/private_azure_load_balancer"
  name                   = "TrustLB-${var.region_shortcode}"
  network_details        = module.vnet.subnets
  resource_group_name    = var.resource_groups.networking_resource_group.name
  location               = var.location
  tags                   = var.common_tags
  networking_definitions = var.networking_definitions
}

resource "azurerm_network_interface_backend_address_pool_association" "obew" {
  for_each                = module.palo_obew.trust_interfaces
  network_interface_id    = each.value.id
  ip_configuration_name   = "ifconfig0"
  backend_address_pool_id = module.trust_lb.azurelb_be_pool.id

  depends_on = [module.trust_lb, module.palo_inbound]
}

