[![terraform](https://img.shields.io/badge/terraform-0.12-brightgreen.svg)](https://www.terraform.io/upgrade-guides/0-12.html)
[![azurerm](https://img.shields.io/badge/azurerm-1.29-brightgreen.svg)](https://github.com/terraform-providers/terraform-provider-azurerm)
[![azurerm](https://img.shields.io/badge/azurerm-2.0-orange.svg)](https://www.terraform.io/docs/providers/azurerm/guides/2.0-upgrade-guide.html)

## Terraform module Virtual Machines(s) [Linux]
This module creates virtual machines with attached NICs to existing subnet, OS and data disk(s).

# Terraform module template
Here goes short description

## Global Inputs [default:string]
### location
The geolocation where the resources are deployed
### rg_name
The name of resource group where the resources are deployed
### vm_prefix
Start of the hostname of the VM
### admin_username
Username of the admin user EUID=0
### ssh_public_keys
List(not yet) of keys of user itadmin (admin user)

## Local Inputs
### vm_size
Size of the VMs to be created
### os_disk_size
Size of the OS disk
### data_disk_size
Size of the data disk(s)
### data_disk_count
Number of data disks to be created
### publisher
Publisher of the image
### offer
Offer of the image
### sku
SKU of the image
### im_version
Version of the image
### stg_acc_type
Storage account type
### os_acc_type
OS account type
### vm_count
Count of the VMs to be created by this module [int]
### group_name
Group name for Ansible dynamic inventory rendering
### dosdisk
Delete OS disk on termination [boolean]
### ddadisk
Delete data disk on termination [boolean]

## Resources
This is the list of resources that the module may create. The module can create zero or more of each of these resources depending on the  count  value. The count value is determined at runtime. The goal of this page is to present the types of resources that may be created.

This list contains all the resources this plus any submodules may create. When using this module, it may create less resources if you use a submodule.

This module defines 5 resources.
 - azurerm_managed_disk
 - azurerm_network_interface
 - azurerm_virtual_machine
 - azurerm_virtual_machine_data_disk_attachment
 - azurerm_public_ip
