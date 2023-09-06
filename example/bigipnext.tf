terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 1.47.0"
    }
  }
}

data "openstack_images_image_v2" "latest_mbip_image" {
  count       = var.mbip_image_name == "latest" ? 0 : 1
  name        = var.mbip_image_name
  most_recent = true
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
  source                       = "../"
  auth_url                     = var.auth_url
  username                     = var.username
  password                     = var.password
  tenant_name                  = var.tenant_name
  availability_zone            = var.availability_zone
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
  mbip_image_name              = data.openstack_images_image_v2.latest_mbip_image[0].id
  num_mbips                    = var.num_mbips
  ssh_username                 = var.ssh_username
  ssh_password                 = var.ssh_password
}

