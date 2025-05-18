variable "tags" {
  description = "This is to define the environment"
}

variable "rg" {
  description = "This is for creating Resource group"
  type = object({
    name     = string
    location = string
  })
}

variable "storage" {
  description = "This is for creating Azure Storage Account"
  type = object({
    name                     = string
    account_replication_type = string
    account_tier             = string
  })

}

variable "container" {
  description = "This is for creating Blob container in Azure Storage"
  type = object({
    name = string
  })

}

variable "fileshare" {
  description = "This is for creating file share in Azure Storage"
  type = object({
    name  = string
    quota = number
  })

}

variable "automation_account" {
  description = "This is for creating Automation Account"
  type = object({
    name     = string
    sku_name = string
  })
}

variable "automation_runbook" {
  description = "This is to create Automation Runbook"
  type = object({
    name         = string
    log_verbose  = string
    log_progress = string
    runbook_type = string
    description  = string
  })
}

variable "publish_content_link" {
  description = "This is to publish script to Azure Automation Runbook"
}

variable "automation_schedule" {
  description = "This is to schedule the job"
  type = object({
    name        = string
    frequency   = string
    interval    = number
    timezone    = string
    description = string
  })

}

variable "local_directory" {
  description = "Local directory path"
  type        = string
  default     = "Devops/UploadFile/*.lck"
}

################################################################################################

# Azure Virtual Desktop Variables
variable "rdsh_count" {
  description = "Number of AVD machines to deploy"
  default     = 2
}

variable "prefix" {
  type        = string
  default     = "avdtf"
  description = "Prefix of the name of the AVD machine(s)"
}

variable "domain_name" {
  type        = string
  default     = "cloudinfra.com"
  description = "Name of the domain to join"
}

variable "domain_user_upn" {
  type        = string
  default     = "rahulks" # do not include domain name as this is appended
  description = "Username for domain join (do not include domain name as this is appended)"
}

variable "domain_password" {
  type        = string
  default     = "Int9871hul!@#"
  description = "Password of the user to authenticate with the domain"
  sensitive   = true
}

variable "vm_size" {
  description = "Size of the machine to deploy"
  default     = "Standard_DS2_v2"
}

variable "ou_path" {
  default = ""
}

variable "local_admin_username" {
  type        = string
  default     = "rahulks"
  description = "local admin username"
}

variable "local_admin_password" {
  type        = string
  default     = "Int9871hul!@#"
  description = "local admin password"
  sensitive   = true
}