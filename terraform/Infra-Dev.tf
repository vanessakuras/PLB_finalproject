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

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "RG-LABS-02" {
  name     = "RG-LABS-02"
  location = "North Europe"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "VPN-LABS-02" {
  name                = "VPN-LABS-02-network"
  address_space       = ["192.168.0.0/16"]
  location            = "France Central"
  resource_group_name = azurerm_resource_group.RG-LABS-02.name
}

# Create subnet
resource "azurerm_subnet" "Subnet-LABS-02" {
  name                 = "DEV-LABS-02-Subnet"
  resource_group_name  = azurerm_resource_group.RG-LABS-02.name
  virtual_network_name = azurerm_virtual_network.VPN-LABS-02.name
  address_prefixes     = ["192.168.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                = "myPublicIP"
    location            = "France Central"
    resource_group_name = azurerm_resource_group.RG-LABS-02.name
    allocation_method   = "Dynamic"
}

# Create Network Security Group1 and Rule
resource "azurerm_network_security_group" "DEV-NSG" {
    name                = "DEV-LABS-02-NetworkSecurityGroup-web-app"
    location            = "France Central"
    resource_group_name = azurerm_resource_group.RG-LABS-02.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "192.168.0.0/16"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "192.168.0.0/16"
        destination_address_prefix = "*"
 }
}

# Create Network Security Group2 and Rule
resource "azurerm_network_security_group" "DEV-NSG2" {
    name                = "DEV-LABS-02-NetworkSecurityGroup-bdd"
    location            = "France Central"
    resource_group_name = azurerm_resource_group.RG-LABS-02.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "192.168.0.0/16"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "sql"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3306"
        source_address_prefix      = "192.168.0.0/16"
        destination_address_prefix = "*"
 }
}

# Create network interface pour machine Dev-web
resource "azurerm_network_interface" "NetIf-LABS-02-web" {
  name                = "NetIf-LABS-02-web-nic"
  location            = "France Central"
  resource_group_name = azurerm_resource_group.RG-LABS-02.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Subnet-LABS-02.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }
}

# Connect the security group to the network interface Dev-web
resource "azurerm_network_interface_security_group_association" "NSG-NetIf-LABS-02-web" {
    network_interface_id      = azurerm_network_interface.NetIf-LABS-02-web.id
    network_security_group_id = azurerm_network_security_group.DEV-NSG.id
}

# Create network interface pour machine Dev-app
resource "azurerm_network_interface" "NetIf-LABS-02-app" {
  name                = "NetIf-LABS-02-app-nic"
  location            = "France Central"
  resource_group_name = azurerm_resource_group.RG-LABS-02.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Subnet-LABS-02.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Connect the security group to the network interface Dev-app
resource "azurerm_network_interface_security_group_association" "NSG-NetIf-LABS-02-app" {
    network_interface_id      = azurerm_network_interface.NetIf-LABS-02-app.id
    network_security_group_id = azurerm_network_security_group.DEV-NSG.id
}

# Create network interface pour machine Dev-bdd
resource "azurerm_network_interface" "NetIf-LABS-02-bdd" {
  name                = "NetIf-LABS-02-bdd-nic"
  location            = "France Central"
  resource_group_name = azurerm_resource_group.RG-LABS-02.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Subnet-LABS-02.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Connect the security group to the network interface Dev-bdd
resource "azurerm_network_interface_security_group_association" "NSG-NetIf-LABS-02-bdd" {
    network_interface_id      = azurerm_network_interface.NetIf-LABS-02-bdd.id
    network_security_group_id = azurerm_network_security_group.DEV-NSG2.id
}

# Create virtual machine Dev-web
resource "azurerm_linux_virtual_machine" "web" {
  name                = "Dev-web"
  resource_group_name = azurerm_resource_group.RG-LABS-02.name
  location            = "France Central"
  size                = "Standard_B1ms"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.NetIf-LABS-02-web.id,
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

# Create virtual machine Dev-app
resource "azurerm_linux_virtual_machine" "app" {
  name                = "Dev-app"
  resource_group_name = azurerm_resource_group.RG-LABS-02.name
  location            = "France Central"
  size                = "Standard_B1ms"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.NetIf-LABS-02-app.id,
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

# Create virtual machine Dev-bdd
resource "azurerm_linux_virtual_machine" "bdd" {
  name                = "Dev-bdd"
  resource_group_name = azurerm_resource_group.RG-LABS-02.name
  location            = "France Central"
  size                = "Standard_B1ms"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.NetIf-LABS-02-bdd.id,
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
