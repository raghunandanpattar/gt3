terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.51.0"
    }
  }
}
provider "azurerm" {

    client_id       = "5e636370-3b89-4d4a-8742-0cc9346f9308"
    tenant_id       = "be4fe9dc-a5f8-4649-b927-a49592994082"
    subscription_id = "d786964d-240f-4088-9247-4ba08f0c47d0"
    client_secret   = "qJH8Q~Klh5-PcjIslNfFcSi9hsUX2YBjFTlYGbtz"

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

variable "vm_admin_username" {}
variable "vm_admin_password" {}

resource "azurerm_resource_group" "tests" {
  name     = "RG-Terraforms"
  location = "East US"

  tags = {
    environment = "group-demo"
  }
}
resource "azurerm_virtual_network" "VNets" {
  name                = "VNets"
  address_space       = ["192.168.0.0/22"]
  location            = azurerm_resource_group.tests.location
  resource_group_name = azurerm_resource_group.tests.name
}

resource "azurerm_subnet" "Subnet-DB" {
  name                 ="Subnet-DB"
  resource_group_name  = azurerm_resource_group.tests.name
  virtual_network_name = azurerm_virtual_network.VNets.name
  address_prefixes     =  ["192.168.0.64/28"]
}
resource "azurerm_network_interface" "nick" {
  name                ="NICK-DB"
  location            = azurerm_resource_group.tests.location
  resource_group_name = azurerm_resource_group.tests.name


  ip_configuration {
    name      = "testconfiguration2"
    subnet_id = azurerm_subnet.Subnet-DB.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_virtual_machine" "AZURE-VM-1" {
  name                  = "VM-DB"
  location              = azurerm_resource_group.tests.location
  resource_group_name   = azurerm_resource_group.tests.name
  network_interface_ids = [azurerm_network_interface.nick.id]
  vm_size               = "Standard_B2s"


  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }
  os_profile {
    computer_name  = "AZ-EUS-L-WB-HCS-VM-DB"
    admin_username = var.vm_admin_username
    admin_password = var.vm_admin_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}
