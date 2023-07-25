terraform {
  required_providers {
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = "~> 3.58.0"
    }
    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "~> 3.5.1"
    }
  }
}

provider "azurerm" {
  features {

  }
}
