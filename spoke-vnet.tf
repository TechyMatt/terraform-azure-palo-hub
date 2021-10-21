resource "azurerm_resource_group" "example" {
  name     = "spoke-test"
  location = "Central US"
  tags = var.tags.common_tags
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.2.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tags = var.tags.common_tags
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.2.2.0/24"]
}

resource "azurerm_network_security_group" "example" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_network_security_rule" "default_deny" {
  name                        = "DefaultDeny"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.example.name
  network_security_group_name = azurerm_network_security_group.example.name
}

resource "azurerm_route_table" "example" {
  name                          = "acceptanceTestSecurityGroup1"
  location                      = azurerm_resource_group.example.location
  resource_group_name           = azurerm_resource_group.example.name
  disable_bgp_route_propagation = true //This is required to not learn the default route from any ExpressRoute

tags = var.tags.common_tags
  
  
}

resource "azurerm_route" "example" {
  name                = "acceptanceTestRoute1"
  resource_group_name = azurerm_resource_group.example.name
  route_table_name    = azurerm_route_table.example.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.networking_definitions["Central US"].trust_lb_ip //Load Balancer in spoke
}

resource "azurerm_subnet_route_table_association" "example" {
  subnet_id      = azurerm_subnet.example.id
  route_table_id = azurerm_route_table.example.id
}


//Peering the vnets together

resource "azurerm_virtual_network_peering" "peerSpokeToHub" {
  name                      = "peerSpokeToHub"
  resource_group_name       = azurerm_resource_group.example.name
  virtual_network_name      = azurerm_virtual_network.example.name
  remote_virtual_network_id = module.palo_hub["Central US"].vnet.id
  use_remote_gateways = true
  depends_on = [module.palo_hub]
}

resource "azurerm_virtual_network_peering" "peerHubToSpoke" {
  name                      = "peerHubToSpoke"
  resource_group_name       = module.resource_groups["Central US"].combined.networking_resource_group.name
  virtual_network_name      = module.palo_hub["Central US"].vnet.name
  remote_virtual_network_id = azurerm_virtual_network.example.id
  allow_forwarded_traffic = true
  allow_virtual_network_access = true
  allow_gateway_transit = true
    depends_on = [module.palo_hub]
}


//Sample Virtual Machine

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
    tags = var.tags.common_tags
}

//https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine
resource "azurerm_windows_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
//Windows Server
/*
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  */

//Windows Desktop wiht O365
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "office-365"
    sku       = "20h2-evd-o365pp"
    version   = "latest"
  }

  identity {
      type = "SystemAssigned"
  }

    tags = var.tags.common_tags
}

//Domain Join Extension
/*
resource "azurerm_virtual_machine_extension" "adjoin" {
  name                 = "${azurerm_windows_virtual_machine.example.name}-adjoin"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  virtual_machine_name = azurerm_windows_virtual_machine.example.name
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  settings = <<SETTINGS
    {
        "Name": "DOMAIN.COM",
        "User": "DOMAIN\\ad-join",
        "OUPath": "OU=Centos,OU=Servers,OU=Operations,DC=NEXT,DC=CLOUD,DC=COM",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "topsecret"
    }
  PROTECTED_SETTINGS

  depends_on = [azurerm_windows_virtual_machine.example]

}
*/