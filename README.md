# OpenStack Modular BIG-IP(mBIP) Module

Terraform module that creates and configures mBIP VMs on OpenStack(VIO).

This module creats mBIP VMs with admin network interface on VIO. you need terraform version 0.14.0 or newer to use this module.

## Usage

```
terraform {
  backend "azurerm" {
    resource_group_name  = "f5pdiqs01-rg"
    storage_account_name = "manovatfstate22173"
    container_name       = "mbiq-demo-tfstate"
    key                  = "mbiq-demos-mbip-demo.tfstate"
  }
}

module "mbip" {
  source             = "git@gitswarm.f5net.com:terraform/modules/openstack/mbip.git?ref=v0.0.1"

  user_name          = var.user_name
  tenant_name        = var.tenant_name
  password           = var.password
  num_mbips          = var.num_mbips
  mbip_name_prefix   = var.mbip_name_prefix
  mbip_image_name    = var.mbip_image_name
  mbip_flavor_name   = var.mbip_flavor_name
  admin_network_name = var.admin_network_name
}
```

## Input

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| admin_network_name | The public admin network name in VIO. | string | - | yes |
| auth_url | The Identity authentication URL | string | `"https://vio-sea.pdsea.f5net.com:5000/v3"` | no |
| availability_zone | Openstack availability zone | string | `"nova"` | no |
| mbip_name_prefix | Name prefix for created mbip prefix | string | - | yes |
| mbip_image_name | The image name for mbip present in VIO | string | - | yes |
| mbip_flavor_name | The flavor name for mbip present in VIO | string | - | yes |
| num_mbips | Number of MBIP instances to create | string | - | yes |
| password | The password for VIO user account | string | - | yes |
| user_name | The user name for VIO user account | string | - | yes |
| tenant_name | The Name of the Tenant or Project to login with | string | - | yes |

## Output

Name | Description | Type
---- | ----------- | ----
admin_ipv4_addresses | The list of created VMs admin ipv4 addresses | list
