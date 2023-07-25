resource random_string main {
  length  = 8
  upper   = false
  special = false

}

resource azurerm_resource_group main {
  name     = "rg-${random_string.main.result}"
  location = var.location
}

data azurerm_subnet LinuxVMSubnet {
  name                 = "Snet-da7insee"
  virtual_network_name = "Vnet-da7insee"
  resource_group_name  = "rg-da7insee"
}

resource azurerm_public_ip LinuxVMPIP {
  name                = "LinuxVMPIP"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
}

resource azurerm_network_interface VMNic {
  name                = "nic-MyLinuxVM1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.LinuxVMSubnet.id
    private_ip_address_allocation = "Dynamic"
  }

  ip_configuration {
    name                          = "external"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.azurerm_subnet.LinuxVMSubnet.id
    public_ip_address_id          = azurerm_public_ip.LinuxVMPIP.id
    primary                       = true
  }
}

data azurerm_key_vault LinuxVMKV {
  name                = "kv-proj3-oz8w05sk"
  resource_group_name = "rg-proj3-oz8w05sk"
}

data azurerm_key_vault_secret ssh_public_key {
  name         = "ssh-public"
  key_vault_id = data.azurerm_key_vault.LinuxVMKV.id
}

resource azurerm_linux_virtual_machine MyLinuxVM1 {
  name                = "vm-MyLinuxVM1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B2ms"
  admin_username      = "adminuser"
  
  network_interface_ids = [
    azurerm_network_interface.VMNic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = data.azurerm_key_vault_secret.ssh_public_key.value
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}