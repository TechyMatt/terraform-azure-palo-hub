variable "environment" {
  default = "Prod"
}

variable "project" {
  default = "Poc"
}

variable "owner" {
  default = "myself"
}

variable "network_tier" {
  default = "Prod"
}

variable "support_team" {
  default = "SNOW group"
}

variable "primary_region" {
  default = "Central US"
}

variable "primary_region_shortcode" {
  default = "CUS"
}

variable "secondary_region" {
  default = "East US 2"
}

variable "secondary_region_shortcode" {
  default = "EUS2"
}

variable "networking_definitions" {
  default = {
    CUS = {
      "address_space"     = ["10.0.0.0/16"]
      "dns_servers"       = ["168.63.129.16"]
      "gatewaysubnet"     = "10.0.0.0/28"
      "subnet_trust"      = "10.0.1.0/24"
      "subnet_management" = "10.0.2.0/24"
      "subnet_untrust"    = "10.0.3.0/24"
      "trust_lb_ip"       = "10.0.1.100"
      nva_configuration = {
        inbound = {
          nva_1 = {
            name                   = "palo-cus-ns-1"
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
          nva_2 = {
            name                   = "palo-cus-ns-2"
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
        obew = {
          nva_1 = {
            name                   = "palo-cus-ew-1"
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
          nva_2 = {
            name                   = "palo-cus-ew-2"
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
    }
    EUS2 = {
      "address_space"     = ["10.1.0.0/16"]
      "dns_servers"       = ["168.63.129.16"]
      "gatewaysubnet"     = "10.1.0.0/28"
      "subnet_trust"      = "10.1.1.0/24"
      "subnet_management" = "10.1.2.0/24"
      "subnet_untrust"    = "10.1.3.0/24"
      "trust_lb_ip"       = "10.1.1.100"
      nva_configuration = {
        inbound = {
          nva_1 = {
            name                   = "palo-eus2-ns-1"
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
          nva_2 = {
            name                   = "palo-eus2-ns-2"
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
        obew = {
          nva_1 = {
            name                   = "palo-eus2-ew-1"
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
          nva_2 = {
            name                   = "palo-eus2-ew-2"
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
    }
  }
}

variable "panorama_server_list" {
  default     = ["192.168.0.1", "192.168.0.2"]
  description = "The FQDN or IP address of the primary Panorama server"
  type        = list(any)
}

variable "express_route_circuit_configurations" {
  default = {
    CUS = {
      production = {
        name                  = "ER-to-Chicago-Production"
        service_provider_name = "Megaport"
        peering_location      = "Chicago"
        bandwidth_in_mbps     = "200"
        tier                  = "Standard"
        family                = "MeteredData"
      }
      management = {
        name                  = "ER-to-Chicago-Management"
        service_provider_name = "Megaport"
        peering_location      = "Chicago"
        bandwidth_in_mbps     = "50"
        tier                  = "Standard"
        family                = "MeteredData"
      }
    }
  }
}

variable "vpn_configurations" {
  default = {
    CUS = {
      production = {
        name            = "CUS-VPN-DR"
        gateway_address = "1.1.1.1"
        address_space   = ["0.0.0.0/1","128.0.0.0/1"]
      }
      management = {
        name            = "CUS-VPN-Management-DR"
        gateway_address = "1.1.1.1"
        address_space   = ["192.168.0.0/24"]
      }
    }
    EUS2 = {
      production = {
        name            = "CUS-VPN-DR"
        gateway_address = "1.1.1.1"
        address_space   = ["0.0.0.0/1","128.0.0.0/1"]

      }
      management = {
        name            = "CUS-VPN-Management-DR"
        gateway_address = "1.1.1.1"
        address_space   = ["192.168.0.0/24"]
      }
    }
  }
}