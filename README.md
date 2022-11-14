# OpenStack BIG-IP Next Module

Terraform module that creates and configures BIG-IP Next instances on OpenStack(VIO).

This module creates BIG-IP Next instances with admin, internal, and external network interfaces on openstack.  An ssh
user with username f5debug and password Welcome123! will be configured. The username and password can be overridden if
desired. You need terraform version 1.2.4 or newer to use this module.

The user used for authenticating with openstack must have the privileges necessary to create ports attached to a subnet
on the internal and external networks.

## Usage

```
terraform {
  backend "azurerm" {
    resource_group_name  = "f5pdiqs01-rg"
    storage_account_name = "manovatfstate22173"
    container_name       = "mbiq-demo-tfstate"
    key                  = "mbiq-demos-mbip-demo.tfstate"
  }

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.47.0"
    }
  }
}

provider "openstack" {
  auth_url    = var.auth_url
  user_name   = var.username
  password    = var.password
  tenant_name = var.tenant_name
  region      = ""
  insecure    = true
}

module "mbip" {
  source                       = "git@gitswarm.f5net.com:terraform/modules/openstack/mbip.git?ref=v0.1.0"

  auth_url                     = var.auth_url
  username                     = var.username
  password                     = var.password
  tenant_name                  = var.tenant_name
  availability_zone            = var.availability_zone
  destroy                      = var.destroy
  mbip_flavor_name             = var.mbip_flavor_name
  admin_network_name           = var.admin_network_name
  network_port_names           = var.network_port_names
  internal_network_name        = var.internal_network_name
  internal_network_subnet_name = var.internal_network_subnet_name
  internal_ip_addresses        = var.internal_ip_addresses
  external_network_name        = var.external_network_name
  external_network_subnet_name = var.external_network_subnet_name
  external_ip_addresses        = var.external_ip_addresses
  mbip_name_prefix             = var.mbip_name_prefix
  mbip_image_name              = var.mbip_image_name
  mbip_release                 = var.mbip_release
  num_mbips                    = var.num_mbips
  ssh_username                 = var.ssh_username
  ssh_password                 = var.ssh_password
}
```

## Input

| Name                              | Description                                                                               |  Type   |                   Default                   | Required |
|-----------------------------------|-------------------------------------------------------------------------------------------|:-------:|:-------------------------------------------:|:--------:|
| auth_url                          | The openstack identity authentication URL.                                                | string  | `"https://vio-sea.pdsea.f5net.com:5000/v3"` |    no    |
| username                          | The username to log in with.                                                              | string  |                      -                      |   yes    |
| password                          | The password to log in with.                                                              | string  |                      -                      |   yes    |
| tenant_name                       | The name of the tenant to create BIG-IP Next instances in.                                | string  |                      -                      |   yes    |
| availability_zone                 | The availability zone to create BIG-IP Next instances in.                                 | string  |                  `"nova"`                   |    no    |
| destroy                           | Whether a terraform destroy is being invoked                                              | boolean |                    false                    |    no    |
| mbip_flavor_name                  | The openstack flavor to use when creating the BIG-IP Next instances.                      | string  |                      -                      |   yes    |
| admin_network_name                | The name of the openstack network to use as the management network.                       | string  |                      -                      |   yes    |
| network_port_names                | List of network port names to attach to BIG-IP Next instances for static IP addresses.    | string  |                     []                      |    no    |
| internal_network_name             | The name of the openstack network to use as the BIG-IP Next internal network.             | string  |                      -                      |   yes    |
| internal_network_subnet_name      | The name of the openstack subnet to use on the BIG-IP Next internal network.              | string  |                      -                      |   yes    |
| internal_ip_addresses             | The list of IP addresses to configure on the BIG-IP Next internal network interface.      | string  |                     []                      |   yes    |
| external_network_name             | The name of the openstack network to use as the BIG-IP Next external network.             | string  |                      -                      |   yes    |
| external_network_subnet_name      | The name of the openstack subnet to use on the BIG-IP Next external network.              | string  |                      -                      |   yes    |
| external_ip_addresses             | The list of IP addresses to configure on the BIG-IP Next external network interface.      | string  |                     []                      |   yes    |
| ha_data_plane_network_name        | The name of the openstack network to use as the BIG-IP Next HA data plane network.        | string  |                      -                      |    no    |
| ha_data_plane_network_subnet_name | The name of the openstack subnet to use on the BIG-IP Next HA data plane network.         | string  |                      -                      |    no    |
| ha_data_plane_ip_addresses        | The list of IP addresses to configure on the BIG-IP Next HA data plane network interface. | string  |                     []                      |    no    |
| mbip_name_prefix                  | The name prefix for BIG-IP Next instances.                                                | string  |                      -                      |   yes    |
| mbip_image_name                   | The openstack image name to use for creating BIG-IP Next instances or latest.             | string  |                 `"latest"`                  |    no    |
| mbip_release                      | The BIG-IP Next release to get the latest image for.                                      | string  |                      -                      |   yes    |
| num_mbips                         | Number of BIG-IP Next instances to create.                                                | string  |                      -                      |   yes    |
| ssh_username                      | The username to configure via cloud-init for ssh access                                   | string  |                   f5debug                   |    no    |
| ssh_password                      | The password to configure via cloud-init for ssh access                                   | string  |                 Welcome123!                 |    no    |

NOTE: When set to true, the destroy variable is used to skip the following unnecessary steps when destroying resources:
- Looking up the latest image when mbip_image_name is set to latest.
- Looking up the named image when mbip_image_name is not set to latest.

## Output

| Name                         | Description                                          | Type   |
|------------------------------|------------------------------------------------------|--------|
| admin_ipv4_addresses         | The list of BIG-IP Next admin ipv4 addresses         | list   |
| internal_ipv4_addresses      | The list of BIG-IP Next internal ipv4 addresses      | list   |
| external_ipv4_addresses      | The list of BIG-IP Next external ipv4 addresses      | list   |
| ha_data_plane_ipv4_addresses | The list of BIG-IP Next HA data plane ipv4 addresses | list   |
| admin_instance_image         | The name of the image used for VM creation           | string |

## Testing

The golang terratest package is used for testing this terraform module. In order to run the tests locally, you must have
go installed and you must create a .env file in the `test` directory that configures the following environment variables
or set all of these environment variables in your environment:

```
TF_VAR_auth_url="https://vio-sea.pdsea.f5net.com:5000/v3"
TF_VAR_username="<VIO username>"
TF_VAR_password="<VIO password>"
TF_VAR_tenant_name="verizon-dcd"
TF_VAR_mbip_flavor_name="m1.xlarge"
TF_VAR_admin_network_name="AdminNetwork2"
TF_VAR_internal_network_name="BIG-IP Next Internal Network"
TF_VAR_internal_network_subnet_name="internal-subnet"
TF_VAR_internal_ip_addresses="[\"10.1.255.1\"]"
TF_VAR_external_network_name="BIG-IP Next External Network"
TF_VAR_external_network_subnet_name="external-subnet"
TF_VAR_external_ip_addresses="[\"10.2.255.1\"]"
TF_VAR_ha_data_plane_network_name="BIG-IP Next HA Network"
TF_VAR_ha_data_plane_network_subnet_name="HA-subnet"
TF_VAR_ha_data_plane_ip_addresses="[\"10.3.255.1\"]"
TF_VAR_mbip_name_prefix="cb-terraform-mbip-test"
TF_VAR_mbip_release="0.7.0"
TF_VAR_num_mbips=1
```

The tests can then be run using the `make test` command.
