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

  tags = local.common_tags
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
  interval_in_seconds = "5"
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
  disable_outbound_snat          = true
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
  disable_outbound_snat          = true
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
  disable_outbound_snat          = true
}

resource "azurerm_lb_rule" "ext_lb_rule_TCP22" {
  name                           = "ext-TCP22-rule"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = azurerm_lb.ext_lb.frontend_ip_configuration[0].name
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.ext_lb_backend_address_pool.id] 
  probe_id                       = azurerm_lb_probe.ext_lb_probe.id
  loadbalancer_id                = azurerm_lb.ext_lb.id
  enable_floating_ip             = true
  disable_outbound_snat          = true
}

resource "azurerm_lb_outbound_rule" "ext_lb_outbound" {
  name                    = "OutboundRule"
  loadbalancer_id         = azurerm_lb.ext_lb.id
  protocol                = "All"
  allocated_outbound_ports = 10240
  backend_address_pool_id = azurerm_lb_backend_address_pool.ext_lb_backend_address_pool.id

  frontend_ip_configuration {
    name = "ClusterPublicIP"
  }
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
    subnet_id = azurerm_subnet.private1subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address = var.intlbaddress
  }
    depends_on = [
    azurerm_virtual_machine.activefgtvm,
    azurerm_virtual_machine.passivefgtvm
  ]

  tags = local.common_tags
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
  interval_in_seconds = "5"
}

# Create intLB Rules
resource "azurerm_lb_rule" "int_lb_rule_all_traffic" {
  name                           = "int-all-traffic-rule"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = azurerm_lb.int_lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.int_lb_backend_address_pool.id] 
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
