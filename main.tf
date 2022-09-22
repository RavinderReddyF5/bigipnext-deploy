terraform {
  required_version = "~> 1.2.4"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.47.0"
    }
  }
}

data "external" "mbip_images" {
  count = var.mbip_image_name == "latest" ? 1 : 0

  program = ["${path.module}/get_latest_image.sh", var.auth_url, var.username, var.password, var.tenant_name, var.mbip_release]
}

data "openstack_images_image_v2" "latest_mbip_image" {
  count = var.mbip_image_name == "latest" ? 0 : 1

  name        = var.mbip_image_name
  most_recent = true
}

data "openstack_networking_network_v2" "admin_network" {
  name  = var.admin_network_name
}

data "openstack_networking_network_v2" "internal_network" {
  name  = var.internal_network_name
}

data "openstack_networking_subnet_v2" "internal_network_subnet" {
  name = var.internal_network_subnet_name
  network_id = data.openstack_networking_network_v2.internal_network.id
}

data "openstack_networking_network_v2" "external_network" {
  name  = var.external_network_name
}

data "openstack_networking_subnet_v2" "external_network_subnet" {
  name = var.external_network_subnet_name
  network_id = data.openstack_networking_network_v2.external_network.id
}

data "openstack_networking_network_v2" "ha_data_plane_network" {
  count = var.ha_data_plane_network_name == "" ? 0 : 1

  name  = var.ha_data_plane_network_name
}

data "openstack_networking_subnet_v2" "ha_data_plane_network_subnet" {
  count = var.ha_data_plane_network_name == "" ? 0 : 1

  name = var.ha_data_plane_network_subnet_name
  network_id = data.openstack_networking_network_v2.ha_data_plane_network.0.id
}

data "openstack_networking_port_v2" "network_port" {
  count = length(var.network_port_names)

  name  = var.network_port_names[count.index]
}

resource "openstack_networking_port_v2" "internal" {
  count = var.num_mbips

  name = "${var.mbip_name_prefix}-${count.index + 1}-internal"
  network_id = data.openstack_networking_network_v2.internal_network.id
  admin_state_up = true
  port_security_enabled = false
  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.internal_network_subnet.id
    ip_address = var.internal_ip_addresses[count.index]
  }
}

resource "openstack_networking_port_v2" "external" {
  count = var.num_mbips

  name = "${var.mbip_name_prefix}-${count.index + 1}-external"
  network_id = data.openstack_networking_network_v2.external_network.id
  admin_state_up = true
  port_security_enabled = false
  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.external_network_subnet.id
    ip_address = var.external_ip_addresses[count.index]
  }
}

resource "openstack_networking_port_v2" "ha_data_plane" {
  count = var.ha_data_plane_network_name == "" ? 0 : var.num_mbips

  name = "${var.mbip_name_prefix}-${count.index + 1}-ha-data-plane"
  network_id = data.openstack_networking_network_v2.ha_data_plane_network.0.id
  admin_state_up = true
  port_security_enabled = false
  fixed_ip {
    subnet_id = data.openstack_networking_subnet_v2.ha_data_plane_network_subnet.0.id
    ip_address = var.ha_data_plane_ip_addresses[count.index]
  }
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
    uuid = length(var.network_port_names) == 0 ? data.openstack_networking_network_v2.admin_network.id : null
    port = length(var.network_port_names) == 0 ? null : data.openstack_networking_port_v2.network_port[count.index].id
  }
  network {
    port = openstack_networking_port_v2.internal[count.index].id
  }
  network {
    port = openstack_networking_port_v2.external[count.index].id
  }
  dynamic "network" {
    for_each = var.ha_data_plane_network_name == "" ? [] : [1]
    content {
      port = openstack_networking_port_v2.ha_data_plane[count.index].id
    }
  }
}
