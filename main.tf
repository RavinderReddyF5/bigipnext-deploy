terraform {
  required_version = "~> 0.15.0"

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

data "external" "mbip_images" {
  count = var.mbip_image_name == "latest" ? 1 : 0

  program = ["${path.module}/get_latest_image.sh", var.user_name, var.password, var.tenant_name]
}

data "openstack_images_image_v2" "latest_mbip_image" {
  count = var.mbip_image_name == "latest" ? 0 : 1

  name        = var.mbip_image_name
  most_recent = true
}

data "openstack_networking_network_v2" "admin_network" {
  count = var.admin_network_name == "" ? 0 : 1
  name = var.admin_network_name
}

data "openstack_networking_port_v2" "network_port" {
  count = length(var.network_port_name)
  name = var.network_port_name[count.index]
}

resource "openstack_compute_instance_v2" "mbip" {
  count             = var.num_mbips
  region            = ""
  availability_zone = var.availability_zone
  name              = "${var.mbip_name_prefix}-${count.index + 1}"
  image_id          = var.mbip_image_name == "latest" ? data.external.mbip_images.0.result.id : data.openstack_images_image_v2.latest_mbip_image.0.id
  flavor_name       = var.mbip_flavor_name
  security_groups   = []
  network {
    uuid = length(var.network_port_name) == 0 ? data.openstack_networking_network_v2.admin_network.0.id : null
    port = length(var.network_port_name) == 0 ? null : data.openstack_networking_port_v2.network_port[count.index].id
  }
}
