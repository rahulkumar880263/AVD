data "azurerm_subscription" "primary" {
}

data "local_file" "automation_account_psscript" {
  filename = "${path.module}/Powershell/DeleteLockFileNew.ps1"
  #content_md5 = filemd5("${path.module}/Powershell/DeleteLockFileNew.ps1")
}

data "local_file" "automation_account_psscript1" {
  filename = "${path.module}/Powershell/Install-Az_Module.ps1"
  #content_md5 = filemd5("${path.module}/Powershell/DeleteLockFileNew.ps1")
}

data "local_file" "files" {
  for_each = fileset(var.local_directory, "**/*")
  filename = each.value
}