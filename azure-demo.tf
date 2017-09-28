resource "azurerm_resource_group" "test" {
  name     = "mdavis-ignite2017TF"
  location = "West US"
}

resource "azurerm_virtual_network" "test" {
  name                = "vnet"
  address_space       = ["10.10.0.0/16"]
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_subnet" "test" {
  name                 = "main"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  virtual_network_name = "${azurerm_virtual_network.test.name}"
  address_prefix       = "10.10.10.0/24"
}

resource "azurerm_public_ip" "test" {
  name = "vm01pip"
  location = "West US"
  resource_group_name = "${azurerm_resource_group.test.name}"
  public_ip_address_allocation = "dynamic"
}

resource "azurerm_network_interface" "test" {
  name                = "host101"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  ip_configuration {
    name                          = "default"
    subnet_id                     = "${azurerm_subnet.test.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = "${azurerm_public_ip.test.id}"
  }
}

resource "azurerm_virtual_machine" "test" {
  name                  = "host1TF"
  location              = "${azurerm_resource_group.test.location}"
  resource_group_name   = "${azurerm_resource_group.test.name}"
  network_interface_ids = ["${azurerm_network_interface.test.id}"]
  vm_size               = "Standard_DS2_v2"

  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "7.3"
    version   = "latest"
  }

  storage_os_disk {
    name              = "host1"
    caching           = "ReadOnly"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "host1"
    admin_username = "mdavis"
    admin_password = "password123!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags {
    vmtype = "webserverTF"
  }

}