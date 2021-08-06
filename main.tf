terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.70.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "2.22.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }

}

provider "azurerm" {
  features {}
}

resource "azurerm_marketplace_agreement" "paloalto" {
  publisher = "paloaltonetworks"
  offer     = "vmseries-flex"
  plan      = "byol"
}

