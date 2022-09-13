// Create Virtual Network

resource "azurerm_virtual_network" "fgtvnetwork" {
  name                = var.vnetname
  address_space       = [var.vnetcidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  tags = local.common_tags
}

resource "azurerm_subnet" "publicsubnet" {
  name                 = "publicSubnet"
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.fgtvnetwork.name
  address_prefixes     = [var.publiccidr]
}

resource "azurerm_subnet" "privatesubnet" {
  name                 = "privateSubnet"
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.fgtvnetwork.name
  address_prefixes     = [var.privatecidr]
}

resource "azurerm_subnet" "hamgmtsubnet" {
  name                 = "HAMGMTSubnet"
  resource_group_name  = azurerm_resource_group.myterraformgroup.name
  virtual_network_name = azurerm_virtual_network.fgtvnetwork.name
  address_prefixes     = [var.hamgmtcidr]
}


// Allocated Public IP
resource "azurerm_public_ip" "ClusterPublicIP" {
  name                = "ClusterPublicIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  sku                 = "Standard"
  allocation_method   = "Static"

  tags = local.common_tags
}

resource "azurerm_public_ip" "ActiveMGMTIP" {
  name                = "ActiveMGMTIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  sku                 = "Standard"
  allocation_method   = "Static"

  tags = local.common_tags
}

resource "azurerm_public_ip" "PassiveMGMTIP" {
  name                = "PassiveMGMTIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  sku                 = "Standard"
  allocation_method   = "Static"

  tags = local.common_tags
}

//  Network Security Group
resource "azurerm_network_security_group" "publicnetworknsg" {
  name                = "PublicNetworkSecurityGroup"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  security_rule {
    name                       = "All"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                        = "egress"
    priority                    = 100
    direction                   = "Outbound"
    access                      = "Allow"
    protocol                    = "*"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
  }


  tags = local.common_tags
}

resource "azurerm_network_security_group" "privatenetworknsg" {
  name                = "PrivateNetworkSecurityGroup"
  location            = var.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name

  security_rule {
    name                       = "All"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                        = "egress"
    priority                    = 100
    direction                   = "Outbound"
    access                      = "Allow"
    protocol                    = "*"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
  }

  tags = local.common_tags
}

# resource "azurerm_network_security_rule" "outgoing_public" {
#   name                        = "egress"
#   priority                    = 100
#   direction                   = "Outbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.myterraformgroup.name
#   network_security_group_name = azurerm_network_security_group.publicnetworknsg.name
# }

# resource "azurerm_network_security_rule" "outgoing_private" {
#   name                        = "egress-private"
#   priority                    = 100
#   direction                   = "Outbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.myterraformgroup.name
#   network_security_group_name = azurerm_network_security_group.privatenetworknsg.name
# }


// Active FGT Network Interface port1
resource "azurerm_network_interface" "activeport1" {
  name                          = "activeport1"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.myterraformgroup.name
  enable_accelerated_networking = var.accelerate == "true" ? true : false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.hamgmtsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.activeport1
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.ActiveMGMTIP.id
  }

  tags = local.common_tags
}

resource "azurerm_network_interface" "activeport2" {
  name                          = "activeport2"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.myterraformgroup.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate == "true" ? true : false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.publicsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.activeport2
    # public_ip_address_id          = azurerm_public_ip.ClusterPublicIP.id
  }

  tags = local.common_tags
}

resource "azurerm_network_interface" "activeport3" {
  name                          = "activeport3"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.myterraformgroup.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate == "true" ? true : false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.privatesubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.activeport3
  }

  tags = local.common_tags
}

# Connect the security group to the network interfaces
resource "azurerm_network_interface_security_group_association" "port1nsg" {
  depends_on                = [azurerm_network_interface.activeport1]
  network_interface_id      = azurerm_network_interface.activeport1.id
  network_security_group_id = azurerm_network_security_group.publicnetworknsg.id
}

resource "azurerm_network_interface_security_group_association" "port2nsg" {
  depends_on                = [azurerm_network_interface.activeport2]
  network_interface_id      = azurerm_network_interface.activeport2.id
  network_security_group_id = azurerm_network_security_group.publicnetworknsg.id
}

resource "azurerm_network_interface_security_group_association" "port3nsg" {
  depends_on                = [azurerm_network_interface.activeport3]
  network_interface_id      = azurerm_network_interface.activeport3.id
  network_security_group_id = azurerm_network_security_group.privatenetworknsg.id
}

// Passive FGT Network Interface port1
resource "azurerm_network_interface" "passiveport1" {
  name                          = "passiveport1"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.myterraformgroup.name
  enable_accelerated_networking = var.accelerate == "true" ? true : false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.hamgmtsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.passiveport1
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.PassiveMGMTIP.id
  }

  tags = local.common_tags
}

resource "azurerm_network_interface" "passiveport2" {
  name                          = "passiveport2"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.myterraformgroup.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate == "true" ? true : false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.publicsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.passiveport2
  }

  tags = local.common_tags
}

resource "azurerm_network_interface" "passiveport3" {
  name                          = "passiveport3"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.myterraformgroup.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = var.accelerate == "true" ? true : false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.privatesubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.passiveport3
  }

  tags = local.common_tags
}

# Connect the security group to the network interfaces
resource "azurerm_network_interface_security_group_association" "passiveport1nsg" {
  depends_on                = [azurerm_network_interface.passiveport1]
  network_interface_id      = azurerm_network_interface.passiveport1.id
  network_security_group_id = azurerm_network_security_group.publicnetworknsg.id
}

resource "azurerm_network_interface_security_group_association" "passiveport2nsg" {
  depends_on                = [azurerm_network_interface.passiveport2]
  network_interface_id      = azurerm_network_interface.passiveport2.id
  network_security_group_id = azurerm_network_security_group.publicnetworknsg.id
}

resource "azurerm_network_interface_security_group_association" "passiveport3nsg" {
  depends_on                = [azurerm_network_interface.passiveport3]
  network_interface_id      = azurerm_network_interface.passiveport3.id
  network_security_group_id = azurerm_network_security_group.privatenetworknsg.id
}

# External Load Balancer
# Create Azure Standard Load Balancer
resource "azurerm_lb" "ext_lb" {
  name                = "ext-lb"
  location            = azurerm_resource_group.myterraformgroup.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  sku = "Standard"
  frontend_ip_configuration {
    name                 = "ClusterPublicIP"
    public_ip_address_id = azurerm_public_ip.ClusterPublicIP.id
  }
  depends_on = [
    azurerm_virtual_machine.activefgtvm,
    azurerm_virtual_machine.passivefgtvm
  ]
}
 
# Create ExtLB Backend Pool
resource "azurerm_lb_backend_address_pool" "ext_lb_backend_address_pool" {
  name                = "ext-lb-backend"
  loadbalancer_id     = azurerm_lb.ext_lb.id
}

# Create ExtLB Probe
resource "azurerm_lb_probe" "ext_lb_probe" {
  name                = "tcp-probe"
  protocol            = "Tcp"
  port                = 8008
  loadbalancer_id     = azurerm_lb.ext_lb.id
}

# Create ExtLB Rules
resource "azurerm_lb_rule" "ext_lb_rule_UDP500" {
  name                           = "ext-UDP500-rule"
  protocol                       = "Udp"
  frontend_port                  = 500
  backend_port                   = 500
  frontend_ip_configuration_name = azurerm_lb.ext_lb.frontend_ip_configuration[0].name
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.ext_lb_backend_address_pool.id]
  probe_id                       = azurerm_lb_probe.ext_lb_probe.id
  loadbalancer_id                = azurerm_lb.ext_lb.id
}

resource "azurerm_lb_rule" "ext_lb_rule_UDP4500" {
  name                           = "ext-UDP4500-rule"
  protocol                       = "Udp"
  frontend_port                  = 4500
  backend_port                   = 4500
  frontend_ip_configuration_name = azurerm_lb.ext_lb.frontend_ip_configuration[0].name
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.ext_lb_backend_address_pool.id]
  probe_id                       = azurerm_lb_probe.ext_lb_probe.id
  loadbalancer_id                = azurerm_lb.ext_lb.id
}

resource "azurerm_lb_rule" "ext_lb_rule_TCP541" {
  name                           = "ext-TCP541-rule"
  protocol                       = "Tcp"
  frontend_port                  = 541
  backend_port                   = 541
  frontend_ip_configuration_name = azurerm_lb.ext_lb.frontend_ip_configuration[0].name
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.ext_lb_backend_address_pool.id] 
  probe_id                       = azurerm_lb_probe.ext_lb_probe.id
  loadbalancer_id                = azurerm_lb.ext_lb.id
  enable_floating_ip             = true
}

# Associate Network Interfaces and ExtLB
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association
resource "azurerm_network_interface_backend_address_pool_association" "ext_activefgt_nic_lb_associate" {
  network_interface_id    = azurerm_network_interface.activeport2.id
  ip_configuration_name   = azurerm_network_interface.activeport2.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.ext_lb_backend_address_pool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "ext_passivefgt_nic_lb_associate" {
  network_interface_id    = azurerm_network_interface.passiveport2.id
  ip_configuration_name   = azurerm_network_interface.passiveport2.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.ext_lb_backend_address_pool.id
}

# internal Load Balancer
# Create Azure Standard Load Balancer
resource "azurerm_lb" "int_lb" {
  name                = "int-lb"
  location            = azurerm_resource_group.myterraformgroup.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  sku = "Standard"
  frontend_ip_configuration {
    name                 = "intLBIP"
    subnet_id = azurerm_subnet.privatesubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address = var.intlbaddress
  }
    depends_on = [
    azurerm_virtual_machine.activefgtvm,
    azurerm_virtual_machine.passivefgtvm
  ]
}

# internal Load Balancer
# Create intLB Backend Pool
resource "azurerm_lb_backend_address_pool" "int_lb_backend_address_pool" {
  name                = "int-lb-backend"
  loadbalancer_id     = azurerm_lb.int_lb.id
}

# Create intLB Probe
resource "azurerm_lb_probe" "int_lb_probe" {
  name                = "tcp-probe"
  protocol            = "Tcp"
  port                = 8008
  loadbalancer_id     = azurerm_lb.int_lb.id
}

# Create intLB Rules
resource "azurerm_lb_rule" "int_lb_rule_all_traffic" {
  name                           = "int-all-traffic-rule"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = azurerm_lb.int_lb.frontend_ip_configuration[0].name
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.int_lb_backend_address_pool.id] 
  probe_id                       = azurerm_lb_probe.int_lb_probe.id
  loadbalancer_id                = azurerm_lb.int_lb.id
    enable_floating_ip             = true
}

# Resource-6: Associate Network interface and intLB
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association
resource "azurerm_network_interface_backend_address_pool_association" "int_activefgt_nic_lb_associate" {
  network_interface_id    = azurerm_network_interface.activeport3.id
  ip_configuration_name   = azurerm_network_interface.activeport3.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.int_lb_backend_address_pool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "int_passivefgt_nic_lb_associate" {
  network_interface_id    = azurerm_network_interface.passiveport3.id
  ip_configuration_name   = azurerm_network_interface.passiveport3.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.int_lb_backend_address_pool.id
}
