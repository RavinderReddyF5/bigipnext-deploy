terraform {
  required_version = "~> 0.14.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.39.0"
    }
  }
}

provider "openstack" {
  user_name   = var.user_name
  tenant_name = var.tenant_name
  password    = var.password
  auth_url    = var.auth_url
  region      = ""
  insecure    = true
}

data "openstack_networking_network_v2" "admin_network" {
  name = var.admin_network_name
}

resource "openstack_compute_instance_v2" "mbip" {
  count             = var.num_mbips
  region            = ""
  availability_zone = var.availability_zone
  name              = "${var.mbip_name_prefix}-${count.index + 1}"
  image_name        = var.mbip_image_name
  flavor_name       = var.mbip_flavor_name
  security_groups   = []
  network {
    uuid = data.openstack_networking_network_v2.admin_network.id
  }
}
