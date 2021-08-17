resource "azurerm_network_interface" "trust" {
  for_each                      = var.nva_details
  name                          = "${each.key}-trust"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = true
  enable_ip_forwarding          = true

  ip_configuration {
    name                          = "ifconfig0"
    subnet_id                     = var.network_details.trust.id
    private_ip_address_allocation = "static"
    private_ip_address            = each.value.trust_ip
  }

  tags = var.tags
}

resource "azurerm_network_interface" "untrust" {
  for_each                      = var.nva_details
  name                          = "${each.key}-untrust"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enable_accelerated_networking = true

  dynamic "ip_configuration" {
  for_each                        = { for k, v in toset(each.value.untrust_ip) : k => k }
        
      content {
        primary = each.value.untrust_ip[0] == ip_configuration.value ? true : false
        name                          = "interface_${ip_configuration.key}"
        subnet_id                     = var.network_details.untrust.id
        private_ip_address_allocation = "static"
        private_ip_address            = ip_configuration.value
      }
    
  }

  tags = var.tags
}

resource "azurerm_network_interface" "management" {
  for_each            = var.nva_details
  name                = "${each.key}-management"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ifconfig0"
    subnet_id                     = var.network_details.management.id
    private_ip_address_allocation = "static"
    private_ip_address            = each.value.management_ip
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "local" {
  for_each                        = { for k, v in var.nva_details : k => v if var.deploy_palo_vms }
  name                            = each.key
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = var.vm_sku
  disable_password_authentication = false
  admin_username                  = var.palo_local_user
  computer_name                   = each.key

  depends_on = [azurerm_network_interface.management, azurerm_network_interface.trust, azurerm_network_interface.untrust]

  admin_password = var.palo_local_password
  zone           = each.value.zone
  network_interface_ids = [
    azurerm_network_interface.management[each.key].id,
    azurerm_network_interface.trust[each.key].id,
    azurerm_network_interface.untrust[each.key].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  plan {
    name      = "byol"
    publisher = "paloaltonetworks"
    product   = "vmseries-flex"
  }

  source_image_reference {
    publisher = "paloaltonetworks"
    offer     = "vmseries-flex"
    sku       = "byol"
    version   = "latest"
  }

  boot_diagnostics {}

  tags = var.tags

  //https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/bootstrap-the-vm-series-firewall/bootstrap-the-vm-series-firewall-in-azure.html
  //https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/sample-init-cfgtxt-file.html#id114bde92-3176-4c7c-a68a-eadfff80cb29
  custom_data = base64encode("type=dhcp-client;op-command-modes=jumbo-frame;vm-series-auto-registration-pin-id=${each.value.registration_pin_id};vm-series-auto-registration-pin-value=${each.value.registration_pin_value};vm-auth-key=${each.value.vm_auth_key};panorama-server=${var.panorama_server_list[0]};panorama-server=${var.panorama_server_list[1]};tplname=${each.value.tplname};dgname=${each.value.dgname}")
}

output "trust_interfaces" {
  value = azurerm_network_interface.trust
}

