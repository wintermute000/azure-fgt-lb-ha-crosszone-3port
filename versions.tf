terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  
  backend "azurerm" {
    resource_group_name  = "loj-infra"
    storage_account_name = "lojinfrastoracc"
    container_name       = "terraform-tfstate"
    key                  = "loj-azure-fgt-lb-ha-crosszone-3port.tfstate"
  }

  required_version = ">= 0.13"
}
