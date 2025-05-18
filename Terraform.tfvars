tags = {
  environment = "Testing"
}

rg = {
  name     = "Test-RG"
  location = "EastUS2"
}

storage = {
  name                     = "teststoragecloudinfra"
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

container = {
  name = "tfstate"
}

fileshare = {
  name  = "fslogix"
  quota = 50
}

automation_account = {
  name     = "testing-automation"
  sku_name = "Basic"
}

automation_runbook = {
  name         = "Testing-PSScript"
  log_verbose  = "true"
  log_progress = "true"
  runbook_type = "PowerShell"
  description  = "This Runbook is to run Powershell script for deleting Lock files from FSlogix file share"
}

publish_content_link = {
  uri = "https://teststoragecloudinfra.blob.core.windows.net/tfstate/DeleteLockFileNew.ps1"
}

automation_schedule = {
  name        = "Runbook-Schedule"
  frequency   = "Day"
  interval    = 1
  timezone    = "America/New_York"
  description = "This is to schedule Automation Account Runbook"

}

####################################################################################################################

# Azure Virtual Desktop variable values defined here:-

# Customized the sample values below for your environment and either rename to terraform.tfvars or env.auto.tfvars

#deploy_location      = "eastus2"
#rg_name              = "Test-RG"
prefix               = "avdtf"
local_admin_username = "RahulKs"
local_admin_password = "Int9871hul!@#"
#vnet_range           = ["10.1.0.0/16"]
#subnet_range         = ["10.1.0.0/24"]
#dns_servers          = ["10.0.1.4", "168.63.129.16"]
#aad_group_name       = "AVDUsers"
domain_name     = "cloudinfra.com"
domain_user_upn = "rahulks" # do not include domain name as this is appended
domain_password = "Int9871hul!@#"
#ad_vnet              = "infra-network"
#ad_rg                = "infra-rg"
/*avd_users = [
  "avduser01@infra.local",
  "avduser01@infra.local"
]*/