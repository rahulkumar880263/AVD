resource "azurerm_virtual_network" "vnet" {
  name                = "AVD-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.ResG.location
  resource_group_name = azurerm_resource_group.ResG.name
}

resource "azurerm_subnet" "subnet" {
  name                                          = "AVD-subnet"
  resource_group_name                           = azurerm_resource_group.ResG.name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = ["10.1.0.0/24"]
  service_endpoints                             = ["Microsoft.Storage"]
  private_endpoint_network_policies             = "Enabled"
  private_link_service_network_policies_enabled = true
}

resource "azurerm_network_security_group" "NSG" {
  name                = "NSG"
  location            = azurerm_resource_group.ResG.location
  resource_group_name = azurerm_resource_group.ResG.name
}

resource "azurerm_subnet_network_security_group_association" "NSG_Assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.NSG.id
}

resource "azurerm_virtual_network_dns_servers" "dnsservers" {
  virtual_network_id = azurerm_virtual_network.vnet.id
  dns_servers        = ["10.0.0.4", "168.63.129.16"]
}

resource "azurerm_virtual_network_peering" "Identity-Vnet-Peering" {
  name                      = "Identity-to-AVD"
  resource_group_name       = "ADDS"
  virtual_network_name      = "DC50Test-01-vnet"
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
}

resource "azurerm_virtual_network_peering" "AVD-Vnet-Peering" {
  name                      = "AVD-to-Identity"
  resource_group_name       = azurerm_resource_group.ResG.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = "/subscriptions/72518812-7f95-4ccf-a0e3-27ee9128be36/resourceGroups/ADDS/providers/Microsoft.Network/virtualNetworks/DC50Test-01-vnet"
}

resource "azurerm_virtual_network_peering" "AVDVnetNew-to-AVD_peering" {
  name                      = "AVDVnetNew-to-AVD"
  resource_group_name       = "AVDNew"
  virtual_network_name      = "AVDNew"
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
}

resource "azurerm_virtual_network_peering" "AVDVnet-to-AVDVNetNew_Peering" {
  name                      = "AVD-to-AVDVNetNew"
  resource_group_name       = azurerm_resource_group.ResG.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = "/subscriptions/72518812-7f95-4ccf-a0e3-27ee9128be36/resourceGroups/AVDNew/providers/Microsoft.Network/virtualNetworks/AVDNew"
}