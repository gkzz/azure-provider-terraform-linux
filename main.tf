# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine
# https://github.com/gkzz/azure-provider-terraform/blob/main/main.tf


terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location

  tags = {
    environment = "${var.environment}"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    environment = "${var.environment}"
  }
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  tags = {
    environment = "${var.environment}"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "${var.prefix}-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_F2"
  admin_username      = "${var.admin_username}"
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  admin_ssh_key {
    username   = "${var.admin_username}"
    #public_key = file("~/.ssh/id_rsa.pub")
    public_key = file(var.ssh_pub_key_path)
  }

  os_disk {
    name                = "${var.prefix}-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    #version   = "latest"
    version   = "18.04.202107200"
  }

  disable_password_authentication = true

  boot_diagnostics {
        #enabled = "true"
        storage_account_uri = azurerm_storage_account.main.primary_blob_endpoint
  }

  tags = {
    environment = "${var.environment}"
  }
}


########################
## https://github.com/terraform-providers/terraform-provider-azurerm/blob/master/examples/virtual-machines/virtual_machine/multiple-network-interfaces/main.tf#L35
resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"

  tags = {
    environment = "${var.environment}"
  }
}


## https://github.com/MicrosoftDocs/azure-dev-docs/blob/master/articles/terraform/create-linux-virtual-machine-with-infrastructure.md
resource "azurerm_network_security_group" "main" {
    name                = "${var.prefix}-nsg"
    location            = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    security_rule {
        name                       = "SSH"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTP"
        priority                   = 120
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTPS"
        priority                   = 130
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
      environment = "${var.environment}"
    }
}

## https://github.com/MicrosoftDocs/azure-dev-docs/blob/master/articles/terraform/create-linux-virtual-machine-with-infrastructure.md
resource "random_id" "main" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.main.name
    }

    byte_length = 8
}

resource "azurerm_storage_account" "main" {
    name                        = "diag${random_id.main.hex}"
    location            = azurerm_resource_group.main.location
    resource_group_name         = azurerm_resource_group.main.name
    account_replication_type    = "LRS"
    account_tier                = "Standard"

    tags = {
        environment = "${var.environment}"
    }
}
