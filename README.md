# Terrform Repository for deploying PaloAlto NVAs into Azure Hubs across multiple regions

## Architecture history History

This code example uses the Transit VNet model located within the Palo Alto reference architecture available at the [Securing Applications in Azure](https://www.paloaltonetworks.com/apps/pan/public/downloadResource?pagePath=/content/pan/en_US/resources/guides/azure-architecture-guide) as the core pattern, however extends to include bootstrapping and other base requirements for a landing zone in Azure, including ExpressRoutes and IPSec VPNs.

![PaloAlto Transit Architecture](images/Palo_Reference_Architecture.png?raw=true "PaloAlto Transit Architecture")

## Overview of deployment

This terraform workspace by default deploys a dual region setup within Azure (Central US & East US 2) deploying seperate Inbound and Outbound East West Palo Altos. The Palo Alto devices are deployed using bootstrapping leveraging Cloud-Init and documentation around that can be located at the [Palo Alto Documentation for Cloud Init](https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/sample-init-cfgtxt-file.html#id114bde92-3176-4c7c-a68a-eadfff80cb29). Settings for the Bootstrapping can be located at the [Palo Alto Bootstrap settings](https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-the-vm-series-firewall-in-azure.html).

To provide consistency for connectivity, a /28 of Public IP prefexis is provision per region. This can be configurable in the networking_definitions_variable if more are required.

## Deployment pre-requisits

- The user executing the script needs to have a minimum of Contributor level access to the target subscription. This is due to the marketplace registration resource.
- Any regions can be chosen, however the code requires that the region supports multiple zones, not just availability sets.
- Connectivity to Panorama Server. If leveraging the ExpressRoute to connect to Panorama then you may need to comment out the resource deployment whilst pending the Circuit Provider provisioning.
  
## Usage instructions

The configuration is controlled by passing in variables either using the command line, or through a .tfvars file. A template of a new region block can be found here. The below documents each field, however due to the inline comments should not be copied and pasted. A complete sample can be located within the [terraform.tfvars](terraform.tfvars) file

```terraform
networking_definitions = {
  "Central US" = { //This needs to be the name of the region to deploy workload
      "region_abbreviation"    = "" //This is a freeform abbreviation of the region
      "hub_vnet_address_space" = [""] //The RFC1918 address space to be used for the hub (minimum /24)
      "regional_azure_networks" = { //This is a list of all networks within the Azure Region (including the hub network).
        "Azure_10.100.0.0_16" = "10.100.0.0/16" //Format should be name = address. The name must contain NO SPACES.
      }
      "dns_servers"       = [""] //A list of DNS Servers that resources should use to query both private and public DNS
      "gatewaysubnet"     = "" //A minimum of /27 (larger if more VPNs) allocated from hub_vnet_address_space
      "subnet_trust"      = "" //A minimum of /26 allocated from hub_vnet_address_space
      "subnet_management" = "" //A minimum of /26 allocated from hub_vnet_address_space
      "subnet_untrust"    = "" //A minimum of /26 allocated from hub_vnet_address_space
      "trust_lb_ip"       = "" //The IP address from the subnet_trust that should be static for the Load Balancer
      "nva_configuration" = {
        "inbound" = { //This section is for the Palo Altos to be used purely for routing inbound traffic
          "" = { //The Device Name of the Palo Alto. Should be unique
            trust_ip               = "" //The IP address to allocate to the trust interface, from subnet_trust
            management_ip          = "" //The IP address to allocate to the management interface, from subnet_management
            untrust_ip             = "" //The IP address to allocate to the untrust interface, from subnet_untrust
            zone                   = "" //The availability zone to deploy the PaloAlto in
            vm_auth_key            = "" //**bootstrap** The authorization key for the Palo to connect to Panorama
            tplname                = "" //**bootstrap** The template name in Panorama to deploy to the device
            dgname                 = "" //**bootstrap** The Device Group name in Panorama to deploy to the device
            registration_pin_id    = "" //**bootstrap** The panorama registration pin id
            registration_pin_value = "" //**bootstrap** The panorama registration pin value
          }
        }
        "obew" = {
          "" = { //The Device Name of the Palo Alto. Should be unique
            trust_ip               = "" //The IP address to allocate to the trust interface, from subnet_trust
            management_ip          = "" //The IP address to allocate to the management interface, from subnet_management
            untrust_ip             = "" //The IP address to allocate to the untrust interface, from subnet_untrust
            zone                   = "" //The availability zone to deploy the PaloAlto in
            vm_auth_key            = "" //**bootstrap** The authorization key for the Palo to connect to Panorama
            tplname                = "" //**bootstrap** The template name in Panorama to deploy to the device
            dgname                 = "" //**bootstrap** The Device Group name in Panorama to deploy to the device
            registration_pin_id    = "" //**bootstrap** The panorama registration pin id
            registration_pin_value = "" //**bootstrap** The panorama registration pin value
          }
        }
      }
      "vpns" = { //This section contains the IPSec VPNs to be deployed. In the event no VPNs are required for this region leave {}
        "" = { //The name of the VPN
          gateway_address = "" //The destination address to connect to
          address_space   = [""] //The destination addresses if BGP not configured
          bgp_settings = { //https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-bgp-overview
            asn = "" //The BGP ASN number. If Blank then no BGP is configured
            bgp_peering_address = "" //The BGP peering address and BGP identifier of this BGP speaker.
            peer_weight = "" //The weight added to routes learned from this BGP speaker.
          }
          pre-shared-key  = "" //The pre-shared key of the IPSec tunnel
        }
      }
      "express_route_gateway_sku = "" https://docs.microsoft.com/en-us/azure/expressroute/expressroute-about-virtual-network-gateways#gwsku
      "express_routes" = { //This section contains the Express Routes. In the event no Express Routes are required for this region leave {}
        "" = { //The name of the ExpressRoute
          service_provider_name = "" //The name of service provider, e.g. MegaPort
          peering_location      = "" //The peering location 
          bandwidth_in_mbps     = "" //The bandwidth of the ExpressRoute
          tier                  = "" //The tier of ExpressRoute (standard or premium)
          family                = "" //The data plan, either MeteredData or Unlimited
          gateway_regions = [""] //Regions to connect ExpressRoute Circuits to
        }
      }
    }
}
```
