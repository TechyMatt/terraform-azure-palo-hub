resource "azurerm_marketplace_agreement" "paloalto" {
  publisher = "paloaltonetworks"
  offer     = "vmseries-flex"
  plan      = "byol"
}


module "resource_groups" {
  for_each           = var.networking_definitions
  source             = "./modules/resource_groups"
  location           = each.key
  location_shortcode = var.networking_definitions[each.key].region_abbreviation
  tags               = var.tags.common_tags
}

module "express_routes" {
  for_each               = var.networking_definitions
  source                 = "./modules/express_route_circuit"
  resource_group_name    = module.resource_groups[each.key].combined.vpn_resource_group.name
  location               = each.key
  networking_definitions = var.networking_definitions
  tags                   = var.tags.common_tags
}

//If pending ExpressRoute enablement, comment out the following resources until provisioned.
module "palo_hub" {
  for_each               = var.networking_definitions
  source                 = "./modules/palo_hub"
  networking_definitions = var.networking_definitions
  location               = each.key
  panorama_server_list   = var.panorama_server_list
  resource_groups        = module.resource_groups[each.key].combined
  tags                   = var.tags
}

module "vpns" {
  for_each               = var.networking_definitions
  source                 = "./modules/local_network_gateway"
  resource_group_name    = module.resource_groups[each.key].combined.vpn_resource_group.name
  location               = each.key
  networking_definitions = var.networking_definitions
  tags                   = var.tags.common_tags
}
