
# AZURE PROVIDER DEFITION

terraform {
  backend "azurerm" {
      resource_group_name = "tstate"
      storage_account_name = "terraformbhrpasa"
      container_name = "terraformbhrpcontainer"
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}




# DEPLOYMENT RESOURCES DEFINITION


#Azure Resourse Group
resource "azurerm_resource_group" "rg-demo" {
  name     = "${var.prefix}${var.environment_abrev}RG"
  location = "${var.location}"

  tags = {
    project = "DemoBH"
    environment= var.environment
  }
}


#Azure Container Registry
resource "azurerm_container_registry" "acr-demo" {
  name                = "${var.prefix}${var.environment_abrev}ACR"
  resource_group_name = azurerm_resource_group.rg-demo.name
  location            = azurerm_resource_group.rg-demo.location
  sku                 = "Basic"
  tags = {
    project = "DemoBH"
    environment= var.environment
  }
}

#Azure Kubernetes Services
resource "azurerm_log_analytics_workspace" "law-demo" {
  name                = "${var.prefix}${var.environment_abrev}LAW"
  resource_group_name = azurerm_resource_group.rg-demo.name
  location            = azurerm_resource_group.rg-demo.location
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "las-demo" {
  solution_name         = "Containers"
  workspace_resource_id = azurerm_log_analytics_workspace.law-demo.id
  workspace_name        = azurerm_log_analytics_workspace.law-demo.name
  resource_group_name = azurerm_resource_group.rg-demo.name
  location            = azurerm_resource_group.rg-demo.location

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Containers"
  }
}

resource "azurerm_kubernetes_cluster" "aks-demo" {
  name                = "${var.prefix}${var.environment_abrev}AKS"
  location            = azurerm_resource_group.rg-demo.location
  resource_group_name = azurerm_resource_group.rg-demo.name
  dns_prefix          = "${var.prefix}${var.environment_abrev}AKS"

  tags = {
    project = "BHRP"
    environment= var.environment
  }

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }


  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.law-demo.id
    }
  }
}