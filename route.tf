# resource "azurerm_route_table" "private1_rt" {
#   name                = "private_rt1"
#   location            = azurerm_resource_group.myterraformgroup.location
#   resource_group_name = azurerm_resource_group.myterraformgroup.name
  
#   # route {
#   #   name           = "internal_subnet"
#   #   address_prefix = var.private1cidr
#   #   next_hop_type  = "VnetLocal"
#   # }

#   # route {
#   #   name           = "internal_vnet"
#   #   address_prefix = var.vnetcidr
#   #   next_hop_type  = "VirtualAppliance"
#   #   next_hop_in_ip_address = var.intlbaddress
#   # }

#   # route {
#   #   name           = "internal_default"
#   #   address_prefix = "0.0.0.0/0"
#   #   next_hop_type  = "VirtualAppliance"
#   #   next_hop_in_ip_address = var.intlbaddress
#   # }

#   tags = local.common_tags

# }

resource "azurerm_route_table" "private2_rt" {
  name                = "private_rt2"
  location            = azurerm_resource_group.myterraformgroup.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  
  # route {
  #   name           = "internal_subnet"
  #   address_prefix = var.private2cidr
  #   next_hop_type  = "VnetLocal"
  # }

  # route {
  #   name           = "internal_vnet"
  #   address_prefix = var.vnetcidr
  #   next_hop_type  = "VirtualAppliance"
  #   next_hop_in_ip_address = var.intlbaddress
  # }

  route {
    name           = "internal_default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = var.intlbaddress
  }

  # route {
  #   name           = "internal_bastion"
  #   address_prefix = "172.30.4.0/26"
  #   next_hop_type  = "VnetLocal"
  # }

  tags = local.common_tags

}

resource "azurerm_route_table" "private3_rt" {
  name                = "private_rt3"
  location            = azurerm_resource_group.myterraformgroup.location
  resource_group_name = azurerm_resource_group.myterraformgroup.name
  
  # route {
  #   name           = "internal_subnet"
  #   address_prefix = var.private3cidr
  #   next_hop_type  = "VnetLocal"
  # }

  # route {
  #   name           = "internal_vnet"
  #   address_prefix = var.vnetcidr
  #   next_hop_type  = "VirtualAppliance"
  #   next_hop_in_ip_address = var.intlbaddress
  # }

  route {
    name           = "internal_default"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = var.intlbaddress
  }

  # route {
  #   name           = "internal_bastion"
  #   address_prefix = "172.30.4.0/26"
  #   next_hop_type  = "VnetLocal"
  # }

  tags = local.common_tags

}



# resource "azurerm_subnet_route_table_association" "private1associate" {
#   depends_on     = [azurerm_route_table.private1_rt]
#   subnet_id      = azurerm_subnet.private1subnet.id
#   route_table_id = azurerm_route_table.private1_rt.id 
# }

resource "azurerm_subnet_route_table_association" "private2associate" {
  depends_on     = [azurerm_route_table.private2_rt]
  subnet_id      = azurerm_subnet.private2subnet.id
  route_table_id = azurerm_route_table.private2_rt.id
}

resource "azurerm_subnet_route_table_association" "private3associate" {
  depends_on     = [azurerm_route_table.private3_rt]
  subnet_id      = azurerm_subnet.private3subnet.id
  route_table_id = azurerm_route_table.private3_rt.id
}

