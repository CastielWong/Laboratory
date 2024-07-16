# -------------------------------------------------------------------------------------
#
# -------------------------------------------------------------------------------------
# define default tags
variable "default_tags" {
  type        = map(string)
  description = "Default tags to be applied to all resources"
  default = {
    DEMO = "Terraform"
  }
}

variable "region" {
  type     = string
  nullable = false
}

variable "user_name" {
  type    = string
  default = "developer"
}
variable "ssh_pub" {
  type     = string
  nullable = false
}
variable "init_file" {
  type     = string
  nullable = false
}

variable "bucket_name" {
  type     = string
  nullable = false
}

# -------------------------------------------------------------------------------------
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "azurerm" {
  features {}

  # subscription_id = ""
  # client_id = ""
  # client_secret = ""
  # tenant_id = ""
}


# # -----------------------------------------------------------------------------
# Resource Group
resource "azurerm_resource_group" "terraform_rg" {
  name     = "TerraformRG"
  location = var.region

  tags = merge(
    var.default_tags,
    {
      Name = "TerraformRG"
    }
  )
}

# create NetworkWatcherRG explicitly, so that all services can be destroyed properly
# https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-create
resource "azurerm_resource_group" "network_watcher_rg" {
  name     = "NetworkWatcherRG"
  location = var.region

  tags = merge(
    var.default_tags,
    {
      Name = "DefaultWatcherRG"
    }
  )
}

# -----------------------------------------------------------------------------
# Virtual Network
resource "azurerm_virtual_network" "terraform_network" {
  name                = "terraform-vnet"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.terraform_rg.name
  location            = azurerm_resource_group.terraform_rg.location

  tags = merge(
    var.default_tags,
    {
      Name = "DemoTerraformNetwork"
    }
  )

  depends_on = [
    azurerm_resource_group.network_watcher_rg
  ]
}

resource "azurerm_network_watcher" "terraform_network_watcher" {
  name                = "terraform-nwwatcher"
  location            = azurerm_resource_group.network_watcher_rg.location
  resource_group_name = azurerm_resource_group.network_watcher_rg.name

  tags = merge(
    var.default_tags,
    {
      Name = "DefaultNetworkWatcher"
    }
  )
}

resource "azurerm_subnet" "terraform_subnet" {
  name                 = "terraform-subnet"
  resource_group_name  = azurerm_resource_group.terraform_rg.name
  virtual_network_name = azurerm_virtual_network.terraform_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "terraform_ip" {
  name                = "terraform-public-ip"
  resource_group_name = azurerm_resource_group.terraform_rg.name
  location            = azurerm_resource_group.terraform_rg.location
  allocation_method   = "Dynamic"

  tags = merge(
    var.default_tags,
    {
      Name = "DemoTerraformPublicIP"
    }
  )
}

# -----------------------------------------------------------------------------
# Compute Instance
resource "azurerm_network_interface" "terraform_nic" {
  name                = "terraform-nic"
  resource_group_name = azurerm_resource_group.terraform_rg.name
  location            = azurerm_resource_group.terraform_rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.terraform_subnet.id
    private_ip_address_version    = "IPv4"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.terraform_ip.id
  }

  tags = merge(
    var.default_tags,
    {
      Name = "TerraformNIC"
    }
  )
}


# # define the template_file data source
# # https://cloudinit.readthedocs.io/en/latest/index.html
# data "template_file" "script" {
#   template = file(var.init_file)
# }
# data "template_cloudinit_config" "config" {
#   gzip          = true
#   base64_encode = true

#   # Main cloud-config configuration file.
#   part {
#     content_type = "text/cloud-config"
#     content      = data.template_file.script.rendered
#   }
# }


resource "azurerm_virtual_machine" "terraform_vm" {
  name                = "terraform-machine"
  resource_group_name = azurerm_resource_group.terraform_rg.name
  location            = azurerm_resource_group.terraform_rg.location

  network_interface_ids = [azurerm_network_interface.terraform_nic.id]
  vm_size               = "Standard_B1s"

  storage_image_reference {
    publisher = "Debian"
    offer     = "debian-10"
    sku       = "10"
    version   = "latest"
  }

  storage_os_disk {
    name              = "terraform-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    disk_size_gb      = "30"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "terraform"
    admin_username = var.user_name

    # custom_data = data.template_cloudinit_config.config.rendered
    custom_data = file(var.init_file)
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.user_name}/.ssh/authorized_keys"
      key_data = file(var.ssh_pub)
    }
  }


  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.terraform.id]
  }

  # VM requires the port to be ready for package update downloading
  depends_on = [azurerm_subnet_network_security_group_association.terraform_nw_sg_association]

  tags = merge(
    var.default_tags,
    {
      Name = "DemoTerraformVM"
    }
  )
}

# create additional disk then attach
resource "azurerm_managed_disk" "terraform_disk" {
  name                = "${azurerm_virtual_machine.terraform_vm.name}-disk"
  resource_group_name = azurerm_resource_group.terraform_rg.name
  location            = azurerm_resource_group.terraform_rg.location

  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 16

  tags = merge(
    var.default_tags,
    {
      Name = "TerraformDisk"
    }
  )
}
resource "azurerm_virtual_machine_data_disk_attachment" "vm_disk_attachment" {
  managed_disk_id    = azurerm_managed_disk.terraform_disk.id
  virtual_machine_id = azurerm_virtual_machine.terraform_vm.id
  lun                = "10"
  caching            = "ReadWrite"
}

# -----------------------------------------------------------------------------
# Network Security Group
resource "azurerm_network_security_group" "terraform_nw_sg" {
  name                = "terraform-network-sg"
  resource_group_name = azurerm_resource_group.terraform_rg.name
  location            = azurerm_resource_group.terraform_rg.location

  security_rule {
    name                       = "SSH"
    priority                   = 1001
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
    priority                   = 1002
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
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(
    var.default_tags,
    {
      Name = "DemoTerraformNetworkSG"
    }
  )
}

resource "azurerm_subnet_network_security_group_association" "terraform_nw_sg_association" {
  subnet_id                 = azurerm_subnet.terraform_subnet.id
  network_security_group_id = azurerm_network_security_group.terraform_nw_sg.id
}

# -----------------------------------------------------------------------------
# Storage
resource "azurerm_storage_account" "terraform_bucket" {
  name                = var.bucket_name
  resource_group_name = azurerm_resource_group.terraform_rg.name
  location            = azurerm_resource_group.terraform_rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = merge(
    var.default_tags,
    {
      Name = "DemoTerraformStorageAccount"
    }
  )
}

resource "azurerm_storage_container" "terraform_container" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.terraform_bucket.name
  container_access_type = "private"
}

# -----------------------------------------------------------------------------
# IAM
resource "azurerm_user_assigned_identity" "terraform" {
  name                = "terraform-identity"
  resource_group_name = azurerm_resource_group.terraform_rg.name
  location            = azurerm_resource_group.terraform_rg.location
}

# assign user to the resource group
resource "azurerm_role_assignment" "terraform_rg_role" {
  principal_id         = azurerm_user_assigned_identity.terraform.principal_id
  scope                = azurerm_resource_group.terraform_rg.id
  role_definition_name = "Contributor"

}

# assign user to the bucket
resource "azurerm_role_assignment" "terraform_storage_role" {
  principal_id         = azurerm_user_assigned_identity.terraform.principal_id
  scope                = azurerm_storage_account.terraform_bucket.id
  role_definition_name = "Storage Blob Data Contributor"
}
