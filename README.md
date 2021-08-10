# Terrform Repository for deploying PaloAlto NVAs into Azure Hubs across multiple regions

## Architecture history History

This repository is based of the Transit VNet model located within the Palo Alto reference architecture available at the [Securing Applications in Azure](https://www.paloaltonetworks.com/apps/pan/public/downloadResource?pagePath=/content/pan/en_US/resources/guides/azure-architecture-guide) on page 61.

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
  "Central US" = {
      "region_abbreviation"    = ""
      "hub_vnet_address_space" = [""]
      "regional_azure_networks" = {
        "Azure_10.100.0.0_16" = "10.100.0.0/16"
      }
      "dns_servers"       = [""]
      "gatewaysubnet"     = ""
      "subnet_trust"      = ""
      "subnet_management" = ""
      "subnet_untrust"    = ""
      "trust_lb_ip"       = ""
      "nva_configuration" = {
        "inbound" = {
          "nva_1" = {
            name                   = ""
            trust_ip               = ""
            management_ip          = ""
            untrust_ip             = ""
            zone                   = ""
            vm_auth_key            = ""
            tplname                = ""
            dgname                 = ""
            registration_pin_id    = ""
            registration_pin_value = ""
          }
        }
        "obew" = {
          "nva_1" = {
            name                   = ""
            trust_ip               = ""
            management_ip          = ""
            untrust_ip             = ""
            zone                   = ""
            vm_auth_key            = ""
            tplname                = ""
            dgname                 = ""
            registration_pin_id    = ""
            registration_pin_value = ""
          }
        }
      }
      "vpns" = {
        "production" = {
          name            = ""
          gateway_address = ""
          address_space   = [""]
          pre-shared-key  = ""
        }
      }
      "express_routes" = { //This section contains the Express Routes. In the event no Express Routes are required for this region leave {}
        "production" = {
          name                  = ""
          service_provider_name = ""
          peering_location      = ""
          bandwidth_in_mbps     = ""
          tier                  = ""
          family                = ""
        }
      }
    }
}
```
