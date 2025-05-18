output "res_group_name" {
  value = var.rg.name
}

output "res_group_location" {
  value = var.rg.location
}

#######################################################

# Output from Azure Virtual Desktop Deployment

output "location" {
  description = "The Azure region"
  value       = azurerm_resource_group.ResG.location
}

output "session_host_count" {
  description = "The number of VMs created"
  value       = var.rdsh_count
}

output "dnsservers" {
  description = "Custom DNS configuration"
  value       = azurerm_virtual_network.vnet.dns_servers
}

output "vnetrange" {
  description = "Address range for deployment vnet"
  value       = azurerm_virtual_network.vnet.address_space
}