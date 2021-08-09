# Terrform Repository for deploying PaloAlto NVAs into Azure Hubs across multiple regions

## Refernece History
This repsitory is based of the Transit VNet model located within the Palo Alto reference architecture available at the [Securing Applications in Azure](https://www.paloaltonetworks.com/apps/pan/public/downloadResource?pagePath=/content/pan/en_US/resources/guides/azure-architecture-guide) on page 61.

![PaloAlto Transit Architecture](images/Palo_Reference_Architecture.png?raw=true "PaloAlto Transit Architecture")

## Overview of deployment
This terraform workspace by default deploys a dual region setup within Azure (Central US & East US 2) deploying seperate Inbound and Outbound East West Palo Altos. The Palo Alto devices are deployed using bootstrapping leveraging Cloud-Init and documentation around that can be located at the [Palo Alto Documentation for Cloud Init](https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/sample-init-cfgtxt-file.html#id114bde92-3176-4c7c-a68a-eadfff80cb29). Settings for the Bootstrapping can be located at the [Palo Alto Bootstrap settings](https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-the-vm-series-firewall-in-azure.html)
  
## Usage instructions

The configuration is controlled by passing in variables either using the command line, or through a .tfvars file.

