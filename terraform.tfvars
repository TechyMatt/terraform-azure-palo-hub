tags = {
  "common_tags" = {
    "environment"  = "Prod"
    "project"      = "POC"
    "owner"        = "Network Admin"
    "network_tier" = "Prod"
    "support_team" = "Network Team"
    "cost_center"  = "000-0000-000-000"
  }
  "compute_tags" = {
    "maintenance_windows" = "Saturday"
  }
}

panorama_server_list = ["192.168.0.1", "192.168.0.2"]

networking_definitions = {
  "Central US" = {
    "region_abbreviation"    = "CUS"
    "hub_vnet_address_space" = ["10.0.0.0/16"]
    "regional_azure_networks" = {
      "Azure_10.100.0.0_16" = "10.100.0.0/16"
      "Azure_10.101.0.0_16" = "10.101.0.0/16"
      "Azure_10.101.0.0_16" = "10.102.0.0/16"
    }
    "dns_servers"       = ["168.63.129.16"]
    "gatewaysubnet"     = "10.0.0.0/24"
    "subnet_trust"      = "10.0.1.0/24"
    "subnet_management" = "10.0.2.0/24"
    "subnet_untrust"    = "10.0.3.0/24"
    "trust_lb_ip"       = "10.0.1.100"
    "nva_configuration" = {
      "inbound" = {
        "palo-cus-ns-1" = {
          trust_ip               = "10.0.1.5"
          management_ip          = "10.0.2.5"
          untrust_ip             = "10.0.3.5"
          zone                   = 1
          vm_auth_key            = "xxxx"
          tplname                = "temp_tmpl"
          dgname                 = "temp_dg"
          registration_pin_id    = "xxxx"
          registration_pin_value = "xxxx"
        }
        "palo-cus-ns-2" = {
          trust_ip               = "10.0.1.6"
          management_ip          = "10.0.2.6"
          untrust_ip             = "10.0.3.6"
          zone                   = 2
          vm_auth_key            = "xxxx"
          tplname                = "temp_tmpl"
          dgname                 = "temp_dg"
          registration_pin_id    = "xxxx"
          registration_pin_value = "xxxx"
        }
      }
      "obew" = {
        "palo-cus-ew-1" = {
          trust_ip               = "10.0.1.50"
          management_ip          = "10.0.2.50"
          untrust_ip             = "10.0.3.50"
          zone                   = 1
          vm_auth_key            = "xxxx"
          tplname                = "temp_tmpl"
          dgname                 = "temp_dg"
          registration_pin_id    = "xxxx"
          registration_pin_value = "xxxx"
        }
        "palo-cus-ew-2" = {
          trust_ip               = "10.0.1.51"
          management_ip          = "10.0.2.51"
          untrust_ip             = "10.0.3.51"
          zone                   = 2
          vm_auth_key            = "xxxx"
          tplname                = "temp_tmpl"
          dgname                 = "temp_dg"
          registration_pin_id    = "xxxx"
          registration_pin_value = "xxxx"
        }
      }
    }
    "vpn_gateway_sku" = "VpnGw1"
    "vpns" = {
      "CUS-VPN-DR" = {
        gateway_address = "1.1.1.1"
        address_space   = ["0.0.0.0/1", "128.0.0.0/1"]
        pre_shared_key  = "test123" //The pre-shared key of the IPSec tunnel

      }
      "CUS-VPN-Management-DR" = {
        gateway_address = "1.1.1.1"
        address_space   = ["192.168.0.0/24"]
        pre_shared_key  = "test123" //The pre-shared key of the IPSec tunnel
      }
    }
    "express_route_gateway_sku" = "ERGw1Az"
    "express_routes" = {
      "ER-to-Chicago-Production" = {
        service_provider_name = "Megaport"
        peering_location      = "Chicago"
        bandwidth_in_mbps     = "200"
        tier                  = "Standard"
        family                = "MeteredData"
        gateway_regions = [
          "Central US",
          "East US2"
        ]
      }
      "ER-to-Chicago-Management" = {
        service_provider_name = "Megaport"
        peering_location      = "Chicago"
        bandwidth_in_mbps     = "50"
        tier                  = "Standard"
        family                = "MeteredData"
        gateway_regions = [
          "Central US",
          "East US2"
        ]
      }
    }
  }
  "East US2" = {
    "region_abbreviation"    = "EUS2"
    "hub_vnet_address_space" = ["10.1.0.0/16"]
    "regional_azure_networks" = {
      "Azure_10.200.0.0_16" = "10.200.0.0/16"
      "Azure_10.201.0.0_16" = "10.201.0.0/16"
      "Azure_10.201.0.0_16" = "10.202.0.0/16"
    }
    "dns_servers"       = ["168.63.129.16"]
    "gatewaysubnet"     = "10.1.0.0/24"
    "subnet_trust"      = "10.1.1.0/24"
    "subnet_management" = "10.1.2.0/24"
    "subnet_untrust"    = "10.1.3.0/24"
    "trust_lb_ip"       = "10.1.1.100"
    "nva_configuration" = {
      "inbound" = {
        "palo-eus2-ns-1" = {
          trust_ip               = "10.1.1.5"
          management_ip          = "10.1.2.5"
          untrust_ip             = "10.1.3.5"
          zone                   = 1
          vm_auth_key            = "xxxx"
          tplname                = "temp_tmpl"
          dgname                 = "temp_dg"
          registration_pin_id    = "xxxx"
          registration_pin_value = "xxxx"
        }
        "palo-eus2-ns-2" = {
          trust_ip               = "10.1.1.6"
          management_ip          = "10.1.2.6"
          untrust_ip             = "10.1.3.6"
          zone                   = 2
          vm_auth_key            = "xxxx"
          tplname                = "temp_tmpl"
          dgname                 = "temp_dg"
          registration_pin_id    = "xxxx"
          registration_pin_value = "xxxx"
        }
      }
      "obew" = {
        "palo-eus2-ew-1" = {
          trust_ip               = "10.1.1.50"
          management_ip          = "10.1.2.50"
          untrust_ip             = "10.1.3.50"
          zone                   = 1
          vm_auth_key            = "xxxx"
          tplname                = "temp_tmpl"
          dgname                 = "temp_dg"
          registration_pin_id    = "xxxx"
          registration_pin_value = "xxxx"
        }
        "palo-eus2-ew-2" = {
          trust_ip               = "10.1.1.51"
          management_ip          = "10.1.2.51"
          untrust_ip             = "10.1.3.51"
          zone                   = 2
          vm_auth_key            = "xxxx"
          tplname                = "temp_tmpl"
          dgname                 = "temp_dg"
          registration_pin_id    = "xxxx"
          registration_pin_value = "xxxx"
        }
      }
    }
    "vpn_gateway_sku" = "VpnGw1"
    "vpns" = {
      "EUS2-VPN-DR" = {
        gateway_address = "1.1.1.1"
        address_space   = ["0.0.0.0/1", "128.0.0.0/1"]
          bgp_settings = {
            asn = "" 
            bgp_peering_address = "" 
            peer_weight = ""
          }
          "pre_shared_key"  = "test123"
      }
      "EUS2-VPN-Management-DR" = {
        gateway_address = "1.1.1.1"
        address_space   = ["192.168.0.0/24"]
          bgp_settings = {
            asn = "" 
            bgp_peering_address = "" 
            peer_weight = ""
          }
          "pre_shared_key"  = "test123"
      }
    }
    "express_route_gateway_sku" = "ERGw1Az"
    "express_routes" = {}
  }
}