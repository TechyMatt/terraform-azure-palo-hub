module "east_us2_resource_groups" {
  source             = "./modules/resource_groups"
  location           = var.secondary_region
  tags               = local.common_tags
  location_shortcode = var.secondary_region_shortcode
}

module "east_us2_hub" {
  source                 = "./modules/palo_hub"
  networking_definitions = var.networking_definitions[var.secondary_region_shortcode]
  location               = var.secondary_region
  common_tags            = local.common_tags
  region_shortcode       = var.secondary_region_shortcode
  panorama_server_list   = var.panorama_server_list
  resource_groups        = module.central_us_resource_groups.combined
}

module "east_us2_express_routes" {
  source              = "./modules/express_route_circuit"
  express_routes      = var.express_route_circuit_configurations[var.secondary_region_shortcode]
  tags                = local.common_tags
  resource_group_name = module.central_us_resource_groups.combined.express_route_resource_group.name
  location            = var.secondary_region
}

module "east_us2_local_network_gateways" {
  source              = "./modules/local_network_gateway"
  vpns                = var.vpn_configurations[var.secondary_region_shortcode]
  tags                = local.common_tags
  resource_group_name = module.central_us_resource_groups.combined.vpn_resource_group.name
  location            = var.secondary_region
}