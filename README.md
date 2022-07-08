# OpenStack BIG-IP Next Module

Terraform module that creates and configures BIG-IP Next instances on OpenStack(VIO).

This module creates BIG-IP Next instances with admin, internal, and external network interfaces on openstack. You need
terraform version 1.2.4 or newer to use this module.

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

  username              = var.username
  password              = var.password
  tenant_name           = var.tenant_name
  mbip_flavor_name      = var.mbip_flavor_name
  admin_network_name    = var.admin_network_name
  internal_network_name = var.internal_network_name
  external_network_name = var.external_network_name
  mbip_name_prefix      = var.mbip_name_prefix
  mbip_image_name       = var.mbip_image_name
  mbip_release          = var.mbip_release
  num_mbips             = var.num_mbips
}
```

## Input

| Name                  | Description                                                                            |  Type  |                   Default                   | Required |
|-----------------------|----------------------------------------------------------------------------------------|:------:|:-------------------------------------------:|:--------:|
| auth_url              | The openstack identity authentication URL.                                             | string | `"https://vio-sea.pdsea.f5net.com:5000/v3"` |    no    |
| username              | The username to log in with.                                                           | string |                      -                      |   yes    |
| password              | The password to log in with.                                                           | string |                      -                      |   yes    |
| tenant_name           | The name of the tenant to create BIG-IP Next instances in.                             | string |                      -                      |   yes    |
| availability_zone     | The availability zone to create BIG-IP Next instances in.                              | string |                  `"nova"`                   |    no    |
| mbip_flavor_name      | The openstack flavor to use when creating the BIG-IP Next instances.                   | string |                      -                      |   yes    |
| admin_network_name    | The name of the openstack network to use as the management network.                    | string |                      -                      |   yes    |
| network_port_names    | List of network port names to attach to BIG-IP Next instances for static IP addresses. | string |                     []                      |    no    |
| internal_network_name | The name of the openstack network to use as the BIG-IP Next internal network.          | string |                      -                      |   yes    |
| external_network_name | The name of the openstack network to use as the BIG-IP Next external network.          | string |                      -                      |   yes    |
| mbip_name_prefix      | The name prefix for BIG-IP Next instances.                                             | string |                      -                      |   yes    |
| mbip_image_name       | The openstack image name to use for creating BIG-IP Next instances or latest.          | string |                 `"latest"`                  |    no    |
| mbip_release          | The BIG-IP Next release to get the latest image for.                                   | string |                      -                      |   yes    |
| num_mbips             | Number of BIG-IP Next instances to create.                                             | string |                      -                      |   yes    |

## Output

| Name                 | Description                                  | Type |
|----------------------|----------------------------------------------|------|
| admin_ipv4_addresses | The list of BIG-IP Next admin ipv4 addresses | list |

## Testing

The golang terratest package is used for testing this terraform module. In order to run the tests locally, you must have
go installed and you must create a .env file in the `test` directory that configures the following environment variables
or set all of these environment variables in your environment:

TF_VAR_auth_url="https://vio-sea.pdsea.f5net.com:5000/v3"
TF_VAR_username="<VIO username>"
TF_VAR_password="<VIO password>"
TF_VAR_tenant_name="verizon-dcd"
TF_VAR_mbip_flavor_name="m1.xlarge"
TF_VAR_admin_network_name="AdminNetwork2"
TF_VAR_internal_network_name="vlan1010"
TF_VAR_external_network_name="vlan1011"
TF_VAR_mbip_name_prefix="cb-terraform-mbip-test"
TF_VAR_mbip_release="0.7.0"
TF_VAR_num_mbips=1

The tests can then be run using the `make test` command.
