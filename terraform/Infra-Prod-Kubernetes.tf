# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
#terraform {
#  required_providers {
#    azurerm = {
#      source  = "hashicorp/azurerm"
#      version = "=2.46.0"
#    }
#  }
#}

# Configure the Microsoft Azure Provider
# provider "azurerm" {
#  features {}
#}

# Create a resource group if it doesn't exist
#resource "azurerm_resource_group" "RG-LABS-02" {
#  name     = "RG-LABS-02"
#  location = "North Europe"
#}

# Create a virtual network within the resource group
#resource "azurerm_virtual_network" "VPN-LABS-02" {
#  name                = "VPN-LABS-02-network"
#  address_space       = ["192.168.0.0/16"]
#  location            = azurerm_resource_group.RG-LABS-02.location
#  resource_group_name = azurerm_resource_group.RG-LABS-02.name
#}

# Create subnet
#resource "azurerm_subnet" "Subnet-LABS-02" {
#  name                 = "DEV-LABS-02-Subnet"
#  resource_group_name  = azurerm_resource_group.RG-LABS-02.name
#  virtual_network_name = azurerm_virtual_network.VPN-LABS-02.name
#  address_prefixes     = ["192.168.1.0/24"]
#}

# Create public IPs
#resource "azurerm_public_ip" "myterraformpublicip" {
#    name                = "myPublicIP"
#    location            = azurerm_resource_group.RG-LABS-02.location
#    resource_group_name = azurerm_resource_group.RG-LABS-02.name
#    allocation_method   = "Dynamic"
#}

# Create Network Security Group and Rule
#resource "azurerm_network_security_group" "DEV-NSG" {
#    name                = "DEV-LABS-02-NetworkSecurityGroup"
#    location            = azurerm_resource_group.RG-LABS-02.location
#    resource_group_name = azurerm_resource_group.RG-LABS-02.name
#
#    security_rule {
#        name                       = "SSH"
#        priority                   = 1001
#        direction                  = "Inbound"
#        access                     = "Allow"
#        protocol                   = "Tcp"
#        source_port_range          = "*"
#        destination_port_range     = "22"
#        source_address_prefix      = "192.168.0.0/16"
#        destination_address_prefix = "*"
#    }
#
#    security_rule {
#        name                       = "http"
#        priority                   = 1002
#        direction                  = "Inbound"
#        access                     = "Allow"
#        protocol                   = "Tcp"
#        source_port_range          = "*"
#        destination_port_range     = "80"
#        source_address_prefix      = "192.168.0.0/16"
#        destination_address_prefix = "*"
#    }
# }

# Create network interface pour machine Kub-Mst
resource "azurerm_network_interface" "NetIf-LABS-02-3" {
 name                = "NetIf-LABS-02-3-nic"
  location            = azurerm_resource_group.RG-LABS-02.location
  resource_group_name = azurerm_resource_group.RG-LABS-02.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Subnet-LABS-02.id
    private_ip_address_allocation = "Dynamic"
#    public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }
}

# Connect the security group to the network interface Kub-Mst
resource "azurerm_network_interface_security_group_association" "NSG-NetIf-LABS-02-3" {
    network_interface_id      = azurerm_network_interface.NetIf-LABS-02-3.id
    network_security_group_id = azurerm_network_security_group.DEV-NSG.id
}

# Create network interface pour machine Kub-wk1
resource "azurerm_network_interface" "NetIf-LABS-02-4" {
  name                = "NetIf-LABS-02-4-nic"
  location            = azurerm_resource_group.RG-LABS-02.location
  resource_group_name = azurerm_resource_group.RG-LABS-02.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Subnet-LABS-02.id
    private_ip_address_allocation = "Dynamic"
  }
}
# Connect the security group to the network interface Kub-wk1
resource "azurerm_network_interface_security_group_association" "NSG-NetIf-LABS-02-4" {
    network_interface_id      = azurerm_network_interface.NetIf-LABS-02-4.id
    network_security_group_id = azurerm_network_security_group.DEV-NSG.id
}

# Create network interface pour machine Kub-wk1
resource "azurerm_network_interface" "NetIf-LABS-02-5" {
  name                = "NetIf-LABS-02-5-nic"
  location            = azurerm_resource_group.RG-LABS-02.location
  resource_group_name = azurerm_resource_group.RG-LABS-02.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Subnet-LABS-02.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Connect the security group to the network interface Kub-wk2
resource "azurerm_network_interface_security_group_association" "NSG-NetIf-LABS-02-5" {
    network_interface_id      = azurerm_network_interface.NetIf-LABS-02-5.id
    network_security_group_id = azurerm_network_security_group.DEV-NSG.id
}

# Create virtual machine Kubernetes Master
resource "azurerm_linux_virtual_machine" "KUB-Mst" {
  name                = "Kub-master"
  resource_group_name = azurerm_resource_group.RG-LABS-02.name
  location            = azurerm_resource_group.RG-LABS-02.location
  size                = "Standard_F2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.NetIf-LABS-02-3.id,
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

# Create virtual machine Kubernetes Worker 1
resource "azurerm_linux_virtual_machine" "KUB-Wk1" {
  name                = "Kub-worker1"
  resource_group_name = azurerm_resource_group.RG-LABS-02.name
  location            = azurerm_resource_group.RG-LABS-02.location
  size                = "Standard_DS1_v2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.NetIf-LABS-02-4.id,
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

# Create virtual machine Kubernetes-Worker2
resource "azurerm_linux_virtual_machine" "KUB-Wk2" {
  name                = "Kub-worker2"
  resource_group_name = azurerm_resource_group.RG-LABS-02.name
  location            = azurerm_resource_group.RG-LABS-02.location
  size                = "Standard_DS1_v2"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.NetIf-LABS-02-5.id,
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
