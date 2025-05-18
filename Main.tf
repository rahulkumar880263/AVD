/*locals {
  hybrid_url  = replace("${azurerm_automation_account.automation_account.dsc_server_endpoint}", ".agentsvc.", ".jrds.")
  hybrid_url2 = replace("${local.hybrid_url}", "/\\/accounts\\//", "/automationAccounts/")
}
*/
resource "azurerm_resource_group" "ResG" {
  name     = var.rg.name
  location = var.rg.location
}

resource "azurerm_storage_account" "StorageAccount" {
  name                     = var.storage.name
  resource_group_name      = azurerm_resource_group.ResG.name
  location                 = azurerm_resource_group.ResG.location
  account_replication_type = var.storage.account_replication_type
  account_tier             = var.storage.account_tier
  min_tls_version          = "TLS1_2"
  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = ["103.71.78.52","103.71.78.19"]
    virtual_network_subnet_ids = [azurerm_subnet.subnet.id, "/subscriptions/72518812-7f95-4ccf-a0e3-27ee9128be36/resourceGroups/AVDNew/providers/Microsoft.Network/virtualNetworks/AVDNew/subnets/AVDNew", "/subscriptions/72518812-7f95-4ccf-a0e3-27ee9128be36/resourceGroups/ADDS/providers/Microsoft.Network/virtualNetworks/DC50Test-01-vnet/subnets/default"]
  }

  azure_files_authentication {
    directory_type = "AD"
    # (1 unchanged attribute hidden)

    active_directory {
      domain_guid         = "231f8a8c-6547-4588-b13b-493df6fa8672"
      domain_name         = "CloudInfra.com"
      domain_sid          = "S-1-5-21-3678195483-1644584537-1418931263"
      forest_name         = "CloudInfra.com"
      netbios_domain_name = "CloudInfra.com"
      storage_sid         = "S-1-5-21-3678195483-1644584537-1418931263-10116"
    }
  }
}



resource "azurerm_private_dns_zone" "Storage_DNS_Zone" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.ResG.name
}

resource "azurerm_private_endpoint" "Private_Endpoint" {
  name                = "Storage_Endpoint"
  location            = azurerm_resource_group.ResG.location
  resource_group_name = azurerm_resource_group.ResG.name
  subnet_id           = azurerm_subnet.subnet.id

  private_dns_zone_group {
    name                 = "Storage_DNS_Zone_Group"
    private_dns_zone_ids = [azurerm_private_dns_zone.Storage_DNS_Zone.id]
  }

  private_service_connection {
    name                           = "Storage_Service_Connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.StorageAccount.id
    subresource_names              = ["file"]
  }

}

resource "azurerm_private_dns_zone_virtual_network_link" "AVDVnet_Storage_DNS_Link" {
  name                  = "Storage-AVDVnet-link"
  resource_group_name   = azurerm_resource_group.ResG.name
  private_dns_zone_name = azurerm_private_dns_zone.Storage_DNS_Zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "ADDSVnet_Storage_DNS_Link1" {
  name                  = "Storage-ADDSVnet-link"
  resource_group_name   = azurerm_resource_group.ResG.name
  private_dns_zone_name = azurerm_private_dns_zone.Storage_DNS_Zone.name
  virtual_network_id    = "/subscriptions/72518812-7f95-4ccf-a0e3-27ee9128be36/resourceGroups/ADDS/providers/Microsoft.Network/virtualNetworks/DC50Test-01-vnet"
}

resource "azurerm_storage_container" "container" {
  name                 = var.container.name
  storage_account_name = azurerm_storage_account.StorageAccount.name
}

resource "azurerm_storage_share" "fileshare" {
  name                 = var.fileshare.name
  storage_account_name = azurerm_storage_account.StorageAccount.name
  quota                = var.fileshare.quota
}


resource "azurerm_storage_account" "StorageAccount1" {
  name                     = "rahultest29"
  resource_group_name      = azurerm_resource_group.ResG.name
  location                 = azurerm_resource_group.ResG.location
  account_replication_type = var.storage.account_replication_type
  account_tier             = var.storage.account_tier
  min_tls_version          = "TLS1_2"
  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = ["103.71.78.52","103.71.78.19"]
    virtual_network_subnet_ids = [azurerm_subnet.subnet.id, "/subscriptions/72518812-7f95-4ccf-a0e3-27ee9128be36/resourceGroups/AVDNew/providers/Microsoft.Network/virtualNetworks/AVDNew/subnets/AVDNew", "/subscriptions/72518812-7f95-4ccf-a0e3-27ee9128be36/resourceGroups/ADDS/providers/Microsoft.Network/virtualNetworks/DC50Test-01-vnet/subnets/default"]
  }

    azure_files_authentication {
    directory_type = "AD"
    # (1 unchanged attribute hidden)

    active_directory {
      domain_guid         = "231f8a8c-6547-4588-b13b-493df6fa8672"
      domain_name         = "CloudInfra.com"
      domain_sid          = "S-1-5-21-3678195483-1644584537-1418931263"
      forest_name         = "CloudInfra.com"
      netbios_domain_name = "CloudInfra.com"
      storage_sid         = "S-1-5-21-3678195483-1644584537-1418931263-34602"
    }
  }
}

resource "azurerm_storage_share" "fileshare1" {
  name                 = var.fileshare.name
  storage_account_name = azurerm_storage_account.StorageAccount1.name
  quota                = var.fileshare.quota
}



resource "azurerm_automation_account" "automation_account" {
  name                          = var.automation_account.name
  location                      = azurerm_resource_group.ResG.location
  resource_group_name           = azurerm_resource_group.ResG.name
  sku_name                      = var.automation_account.sku_name
  public_network_access_enabled = false

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = var.tags.environment
  }
}

resource "azurerm_private_dns_zone" "Automation_DNS_Zone" {
  name                = "privatelink.azure-automation.net"
  resource_group_name = azurerm_resource_group.ResG.name
}

resource "azurerm_private_endpoint" "Automation_Endpoint" {
  name                = "Automation_Endpoint"
  location            = azurerm_resource_group.ResG.location
  resource_group_name = azurerm_resource_group.ResG.name
  subnet_id           = azurerm_subnet.subnet.id

  private_dns_zone_group {
    name                 = "Automation_DNS_Zone_Group"
    private_dns_zone_ids = [azurerm_private_dns_zone.Automation_DNS_Zone.id]
  }

  private_service_connection {
    name                           = "Automation_Service_Connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_automation_account.automation_account.id
    subresource_names              = ["DSCAndHybridWorker"]
  }

}

resource "azurerm_private_dns_zone_virtual_network_link" "AVDVnet_Automation_DNS_Link" {
  name                  = "Automation-AVDVnet-link"
  resource_group_name   = azurerm_resource_group.ResG.name
  private_dns_zone_name = azurerm_private_dns_zone.Automation_DNS_Zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "ADDSVnet_Automation_DNS_Link1" {
  name                  = "Automation-ADDSVnet-link"
  resource_group_name   = azurerm_resource_group.ResG.name
  private_dns_zone_name = azurerm_private_dns_zone.Automation_DNS_Zone.name
  virtual_network_id    = "/subscriptions/72518812-7f95-4ccf-a0e3-27ee9128be36/resourceGroups/ADDS/providers/Microsoft.Network/virtualNetworks/DC50Test-01-vnet"
}


/*resource "azurerm_automation_runbook" "automation_runbook" {
  name                    = var.automation_runbook.name
  location                = var.rg.location
  resource_group_name     = var.rg.name
  automation_account_name = var.automation_account.name
  log_verbose             = var.automation_runbook.log_verbose
  log_progress            = var.automation_runbook.log_progress
  description             = var.automation_runbook.description
  runbook_type            = var.automation_runbook.runbook_type

  publish_content_link {
    uri = var.publish_content_link.uri
  }
}*/


resource "azurerm_automation_hybrid_runbook_worker_group" "Runbook_Worker_Group" {
  name                    = "RunBook_Worker_Group"
  resource_group_name     = azurerm_resource_group.ResG.name
  automation_account_name = azurerm_automation_account.automation_account.name
}


resource "azurerm_network_interface" "Nic_Windows" {
  name                = "WindowsVM-nic"
  location            = azurerm_resource_group.ResG.location
  resource_group_name = azurerm_resource_group.ResG.name


  ip_configuration {
    name                          = "vm-example"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "WindowsServerVM" {
  name                = "RunBookVM"
  location            = azurerm_resource_group.ResG.location
  resource_group_name = azurerm_resource_group.ResG.name

  size           = "Standard_B2s"
  admin_username = "RahulKS"
  admin_password = "Int9891hul!@#"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface_ids = [azurerm_network_interface.Nic_Windows.id]

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_virtual_machine_extension" "hwge-registration" {
  name                       = "${azurerm_automation_account.automation_account.name}-hybridworkerextension"
  virtual_machine_id         = azurerm_windows_virtual_machine.WindowsServerVM.id
  publisher                  = "Microsoft.Azure.Automation.HybridWorker"
  type                       = "HybridWorkerForWindows"
  type_handler_version       = "1.1"
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true


  settings = <<SETTINGS
  {
    "AutomationAccountURL" : "${azurerm_automation_account.automation_account.hybrid_service_url}"
  }
  SETTINGS
}

resource "azurerm_automation_hybrid_runbook_worker" "Hybrid_Runbook" {
  resource_group_name     = azurerm_resource_group.ResG.name
  automation_account_name = azurerm_automation_account.automation_account.name
  worker_group_name       = azurerm_automation_hybrid_runbook_worker_group.Runbook_Worker_Group.name
  vm_resource_id          = azurerm_windows_virtual_machine.WindowsServerVM.id
  worker_id               = "00000000-0000-0000-0000-000000000001" #unique uuid
}

resource "azurerm_automation_runbook" "automation_runbook" {
  name                    = var.automation_runbook.name
  location                = azurerm_resource_group.ResG.location
  resource_group_name     = azurerm_resource_group.ResG.name
  automation_account_name = azurerm_automation_account.automation_account.name
  log_verbose             = var.automation_runbook.log_verbose
  log_progress            = var.automation_runbook.log_progress
  description             = var.automation_runbook.description
  runbook_type            = var.automation_runbook.runbook_type

  content = data.local_file.automation_account_psscript.content
}

resource "azurerm_automation_runbook" "automation_runbook1" {
  name                    = "Install-AzModule"
  location                = azurerm_resource_group.ResG.location
  resource_group_name     = azurerm_resource_group.ResG.name
  automation_account_name = azurerm_automation_account.automation_account.name
  log_verbose             = var.automation_runbook.log_verbose
  log_progress            = var.automation_runbook.log_progress
  description             = var.automation_runbook.description
  runbook_type            = var.automation_runbook.runbook_type

  content = data.local_file.automation_account_psscript1.content
}

resource "azurerm_automation_schedule" "automation_runbook_schedule1" {
  name                    = "Module-Installation"
  resource_group_name     = azurerm_resource_group.ResG.name
  automation_account_name = azurerm_automation_account.automation_account.name
  frequency               = "OneTime"
  #interval               = var.automation_schedule.interval
  #start_time             = var.automation_schedule.start_time
  timezone    = var.automation_schedule.timezone
  description = var.automation_schedule.description
}

resource "azurerm_automation_schedule" "automation_runbook_schedule" {
  name                    = var.automation_schedule.name
  resource_group_name     = azurerm_resource_group.ResG.name
  automation_account_name = azurerm_automation_account.automation_account.name
  frequency               = var.automation_schedule.frequency
  interval                = var.automation_schedule.interval
  timezone                = var.automation_schedule.timezone
  start_time              = "${substr(timeadd(timestamp(), "24h"), 0, 10)}T08:00:00+02:00"
  description             = var.automation_schedule.description
}

resource "azurerm_automation_job_schedule" "Job1" {
  resource_group_name     = azurerm_resource_group.ResG.name
  automation_account_name = azurerm_automation_account.automation_account.name
  runbook_name            = azurerm_automation_runbook.automation_runbook1.name
  schedule_name           = azurerm_automation_schedule.automation_runbook_schedule1.name
  run_on                  = azurerm_automation_hybrid_runbook_worker_group.Runbook_Worker_Group.name
  timeouts {

  }
}

resource "azurerm_automation_job_schedule" "Job2" {
  resource_group_name     = azurerm_resource_group.ResG.name
  automation_account_name = azurerm_automation_account.automation_account.name
  runbook_name            = azurerm_automation_runbook.automation_runbook.name
  schedule_name           = azurerm_automation_schedule.automation_runbook_schedule.name
  run_on                  = azurerm_automation_hybrid_runbook_worker_group.Runbook_Worker_Group.name
}


#######################################################################################################
# Azure Virtual Desktop Deployment Configuration
#######################################################################################################

/* locals {
  registration_token = azurerm_virtual_desktop_host_pool_registration_info.registrationinfo.token
}

resource "random_string" "AVD_local_password" {
  count            = var.rdsh_count.count
  length           = 16
  special          = true
  min_special      = 2
  override_special = "*!@#?"
}

resource "azurerm_network_interface" "avd_vm_nic" {
  count               = var.rdsh_count.count
  name                = "${var.prefix}-${count.index + 1}-nic"
  resource_group_name = var.rg.name
  location            = var.rg.location

  ip_configuration {
    name                          = "nic${count.index + 1}_config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
  }

  depends_on = [
    azurerm_resource_group.ResG
  ]
}

resource "azurerm_windows_virtual_machine" "avd_vm" {
  count                 = var.rdsh_count.count
  name                  = "${var.prefix}-${count.index + 1}"
  resource_group_name   = azurerm_resource_group.ResG.name
  location              = azurerm_resource_group.ResG.location
  size                  = var.vm_size
  network_interface_ids = ["${azurerm_network_interface.avd_vm_nic.*.id[count.index]}"]
  provision_vm_agent    = true
  admin_username        = var.local_admin_username
  admin_password        = var.local_admin_password

  os_disk {
    name                 = "${lower(var.prefix)}-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h2-evd"
    version   = "latest"
  }

  depends_on = [
    azurerm_resource_group.ResG,
    azurerm_network_interface.avd_vm_nic
  ]
}

resource "azurerm_virtual_machine_extension" "domain_join" {
  count                      = var.rdsh_count.count
  name                       = "${var.prefix}-${count.index + 1}-domainJoin"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "Name": "${var.domain_name}",
      "OUPath": "${var.ou_path}",
      "User": "${var.domain_user_upn}@${var.domain_name}",
      "Restart": "true",
      "Options": "3"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "${var.domain_password}"
    }
PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }

  depends_on = [
    network.azurerm_virtual_network_peering.identity-vnet-Peering,
    network.azurerm_virtual_network_peering.AVD-Vnet-Peering
  ]
}

resource "azurerm_virtual_machine_extension" "vmext_dsc" {
  count                      = var.rdsh_count.count
  name                       = "${var.prefix}${count.index + 1}-avd_dsc"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${azurerm_virtual_desktop_host_pool.hostpool.name}"
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${local.registration_token}"
    }
  }
PROTECTED_SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.domain_join,
    azurerm_virtual_desktop_host_pool.hostpool
  ]
} */