#comes from global vars
variable "location" {
  description = "The geolocation where the resources are deployed"
}

variable "rg_name" {
  description = "The name of resource group where the resources are deployed"
}

variable "vm_prefix" {
  description = "Start of the hostname of the VM"
}

variable "admin_username" {
  description = "Username of the admin user EUID=0"
}

#comes from module definition
variable "vm_size" {
}

variable "os_disk_size" {
}

variable "data_disk_size" {
}

variable "data_disk_count" {
}

variable "publisher" {
}

variable "offer" {
}

variable "sku" {
}

variable "im_version" {
}

variable "stg_acc_type" {
}

variable "os_acc_type" {
}

variable "vm_count" {
}

variable "group_name" {
}

variable "dosdisk" {
}

variable "ddadisk" {
}

variable "availability_set_id" {
  default = null
}

variable "backend_pool_id" {
  default = null
}
variable "secret_url" { default = null }
variable "source_vault_id" { default = null }
variable "key_url" { default = null }
variable "network_security_group_id" { default = null }
variable "encrypted" { default = false }
variable "disable_password_authentication" { default = false }
variable "admin_password" { default = null }
