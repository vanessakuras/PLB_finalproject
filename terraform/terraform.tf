# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "RG-LABS-02" {
  name     = "RG-LABS-02"
  location = "North Europe"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "VPN-LABS-02" {
  name                = "VPN-LABS-02-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.RG-LABS-02.location
  resource_group_name = azurerm_resource_group.RG-LABS-02.name
}

resource "azurerm_subnet" "Subnet-LABS-02" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.RG-LABS-02.name
  virtual_network_name = azurerm_virtual_network.VPN-LABS-02.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "NetIf-LABS-02" {
  name                = "NetIf-LABS-02-nic1"
  location            = azurerm_resource_group.RG-LABS-02.location
  resource_group_name = azurerm_resource_group.RG-LABS-02.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Subnet-LABS-02.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "NetIf-LABS-02-1" {
  name                = "NetIf-LABS-02-1-nic"
  location            = azurerm_resource_group.RG-LABS-02.location
  resource_group_name = azurerm_resource_group.RG-LABS-02.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Subnet-LABS-02.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "NetIf-LABS-02-2" {
  name                = "NetIf-LABS-02-2-nic"
  location            = azurerm_resource_group.RG-LABS-02.location
  resource_group_name = azurerm_resource_group.RG-LABS-02.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Subnet-LABS-02.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "web" {
  name                = "web-machine"
  resource_group_name = azurerm_resource_group.RG-LABS-02.name
  location            = azurerm_resource_group.RG-LABS-02.location
  size                = "Standard_F2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.NetIf-LABS-02.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "app" {
  name                = "app-machine"
  resource_group_name = azurerm_resource_group.RG-LABS-02.name
  location            = azurerm_resource_group.RG-LABS-02.location
  size                = "Standard_F2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.NetIf-LABS-02-1.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "bdd" {
  name                = "bdd-machine"
  resource_group_name = azurerm_resource_group.RG-LABS-02.name
  location            = azurerm_resource_group.RG-LABS-02.location
  size                = "Standard_F2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.NetIf-LABS-02-2.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
