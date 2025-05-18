resource "azurerm_role_assignment" "Storage_Account" {
  scope                = azurerm_storage_account.StorageAccount.id
  role_definition_name = "Storage File Data Privileged Contributor"
  principal_id         = azurerm_automation_account.automation_account.identity[0].principal_id
}


resource "azurerm_role_assignment" "Subscription" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Reader"
  principal_id         = azurerm_automation_account.automation_account.identity[0].principal_id
}

/*
resource "azurerm_role_assignment" "VM_RBAC" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Reader"
  principal_id         = azurerm_windows_virtual_machine.WindowsServerVM.identity[0].principal_id
}

resource "azurerm_role_assignment" "VM_RBAC_Share" {
  scope                = azurerm_storage_account.StorageAccount.id
  role_definition_name = "Storage File Data Privileged Contributor"
  principal_id         = azurerm_windows_virtual_machine.WindowsServerVM.identity[0].principal_id
}*/
