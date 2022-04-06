# OpenStack Modular BIG-IP(mBIP) Module

Terraform module that creates and configures mBIP VMs on OpenStack(VIO).

This module creats mBIP VMs with admin network interface on VIO. you need terraform version 0.15.0 or newer to use this module.

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
  source                = "git@gitswarm.f5net.com:terraform/modules/openstack/mbip.git?ref=v0.1.0"

  user_name             = var.user_name
  tenant_name           = var.tenant_name
  password              = var.password
  num_mbips             = var.num_mbips
  mbip_name_prefix      = var.mbip_name_prefix
  mbip_image_name       = var.mbip_image_name
  mbip_flavor_name      = var.mbip_flavor_name
  admin_network_name    = var.admin_network_name
  internal_network_name = var.internal_network_name
  external_network_name = var.external_network_name
}
```

## Input

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| admin_network_name | The public admin network name in VIO. | string | - | yes |
| internal_network_name | The network name in VIO to use for the internal network. | string | - | yes |
| external_network_name | The network name in VIO to use for the external network. | string | - | yes |
| auth_url | The Identity authentication URL | string | `"https://vio-sea.pdsea.f5net.com:5000/v3"` | no |
| availability_zone | Openstack availability zone | string | `"nova"` | no |
| mbip_name_prefix | Name prefix for created mbip prefix | string | - | yes |
| mbip_image_name | The image name for mbip present in VIO | string | `"latest"` | no |
| mbip_flavor_name | The flavor name for mbip present in VIO | string | - | yes |
| num_mbips | Number of MBIP instances to create | string | - | yes |
| password | The password for VIO user account | string | - | yes |
| user_name | The user name for VIO user account | string | - | yes |
| tenant_name | The Name of the Tenant or Project to login with | string | - | yes |
| create_cluster_ip | Flag to indicate creation of Cluster IP | string | `"no"` | no |
| mbip_ha_pool_name | Name of the Pool used for Cluster IP creation | string | `"k8s-ext"` | no |

## Output

Name | Description | Type
---- | ----------- | ----
admin_ipv4_addresses | The list of created VMs admin ipv4 addresses | list

## Testing

The golang terratest package is used for testing this terraform module. In order to run the tests locally, you must have
go installed and you must create a .env file in the `test` directory that configures the following environment variables
or set all of these environment variables in your environment:

TF_VAR_auth_url="https://vio-sea.pdsea.f5net.com:5000/v3"
TF_VAR_admin_network_name="AdminNetwork2"
TF_VAR_internal_network_name="vlan1010"
TF_VAR_external_network_name="vlan1011"
TF_VAR_mbip_name_prefix="cb-terraform-mbip-test"
TF_VAR_mbip_flavor_name="m1.large"
TF_VAR_num_mbips=1
TF_VAR_tenant_name="verizon-dcd"
TF_VAR_user_name="<VIO username>"
TF_VAR_password="<VIO password>"

The tests can then be run using the `make test` command.
