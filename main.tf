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
  for_each                     = var.express_route_definitions
  source                       = "./modules/express_route_circuit"
  resource_group_name          = module.resource_groups[each.value.azure_region].combined.express_route_resource_group.name
  location                     = each.value.azure_region
  express_route_definitions    = var.express_route_definitions[each.key]
  tags                         = var.tags.common_tags
  name                         = each.key
  configure_er_private_peering = var.configure_er_private_peering
  depends_on                   = [module.resource_groups]
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
  deploy_palo_vms        = var.deploy_palo_vms

  depends_on = [module.resource_groups]
}
/*
module "vpns" {
  for_each                = var.networking_definitions
  source                  = "./modules/local_network_gateway"
  resource_group_name     = module.resource_groups[each.key].combined.networking_resource_group.name
  location                = each.key
  networking_definitions  = var.networking_definitions
  tags                    = var.tags.common_tags
  subnets                 = module.palo_hub[each.key].subnets

  depends_on = [module.palo_hub]
}

module "express_route_gateway" {
  for_each                       = var.networking_definitions
  source                         = "./modules/express_route_virtual_network_gateway"
  resource_group_name            = module.resource_groups[each.key].combined.networking_resource_group.name
  location                       = each.key
  networking_definitions         = var.networking_definitions
  tags                           = var.tags.common_tags
  subnets                        = module.palo_hub[each.key].subnets
  express_route_circuits         = module.express_routes
  connect_er_circuits_to_gateway = var.connect_er_circuits_to_gateway

  depends_on = [module.vpns]
}
*/