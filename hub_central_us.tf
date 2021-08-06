module "central_us_resource_groups" {
  source             = "./modules/resource_groups"
  location           = var.primary_region
  tags               = local.common_tags
  location_shortcode = var.primary_region_shortcode
}

module "central_us_hub" {
  source                 = "./modules/palo_hub"
  networking_definitions = var.networking_definitions[var.primary_region_shortcode]
  location               = var.primary_region
  common_tags            = local.common_tags
  region_shortcode       = var.primary_region_shortcode
  panorama_server_list   = var.panorama_server_list
  resource_groups        = module.central_us_resource_groups.combined
}

module "central_us_express_routes" {
  source              = "./modules/express_route_circuit"
  express_routes      = var.express_route_circuit_configurations[var.primary_region_shortcode]
  tags                = local.common_tags
  resource_group_name = module.central_us_resource_groups.combined.express_route_resource_group.name
  location            = var.primary_region
}

module "central_us_local_network_gateways" {
  source              = "./modules/local_network_gateway"
  vpns                = var.vpn_configurations[var.primary_region_shortcode]
  tags                = local.common_tags
  resource_group_name = module.central_us_resource_groups.combined.vpn_resource_group.name
  location            = var.primary_region
}
/*
module "central_us_virtual_network_gateways" {
  source              = "./modules/virtual_network_gateway"
  vpns                = var.vpn_configurations[var.primary_region_shortcode]
  tags                = local.common_tags
  resource_group_name = module.central_us_resource_groups.combined.vpn_resource_group.name
  location            = var.primary_region
}
*/