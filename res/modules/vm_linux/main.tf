resource "azurerm_public_ip" "jb_ip" {
  count               = var.public_ip == true ? 1 : 0
  name                = "${var.prefix}-${var.tags["fnc"]}-${var.count_index}-pip"
  resource_group_name = var.rg_name
  location            = var.region
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.prefix}-${terraform.workspace}-jb-${var.count_index}"
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.prefix}-${var.tags["fnc"]}-${var.count_index}-nic"
  resource_group_name = var.rg_name
  location            = var.region

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip == true ? azurerm_public_ip.jb_ip[0].id : ""
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.prefix}-${var.tags["fnc"]}-${var.count_index}"
  resource_group_name = var.rg_name
  location            = var.region
  size                = coalesce(var.size, var.default_size)
  admin_username      = var.username
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  admin_ssh_key {
    username   = var.username
    public_key = var.ssh_pub_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = var.image.publisher
    offer     = var.image.offer
    sku       = var.image.sku
    version   = var.image.version
  }

  plan {
    name      = var.image.sku
    product   = var.image.offer
    publisher = var.image.publisher
  }

  tags = var.tags
}

data "azurerm_public_ip" "jb_ip" {
  depends_on          = [azurerm_linux_virtual_machine.vm]
  count               = var.public_ip == true ? 1 : 0
  name                = "${var.prefix}-${var.tags["fnc"]}-${var.count_index}-pip"
  resource_group_name = var.rg_name
}
