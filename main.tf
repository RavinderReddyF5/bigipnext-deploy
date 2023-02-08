terraform {
  required_version = "> 1.2.4"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.47.0"
    }
  }
}


data "openstack_images_image_v2" "latest_mbip_image" {
  count = var.mbip_image_name == "latest" || var.destroy ? 0 : 1

  name        = var.mbip_image_name
  most_recent = true
}

data "openstack_networking_network_v2" "admin_network" {
  name  = var.admin_network_name
}

data "openstack_networking_network_v2" "external_network" {
  name  = var.external_network_name
}

data "openstack_networking_subnet_v2" "external_network_subnet" {
  name = var.external_network_subnet_name
  network_id = data.openstack_networking_network_v2.external_network.id
}

data "openstack_networking_port_v2" "network_port" {
  count = length(var.network_port_names)

  name  = var.network_port_names[count.index]
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

resource "openstack_compute_instance_v2" "mbip" {
  count             = var.num_mbips
  region            = ""
  availability_zone = var.availability_zone
  name              = "${var.mbip_name_prefix}-${count.index + 1}"
  image_id          = var.destroy ? null : data.openstack_images_image_v2.latest_mbip_image.0.id
  flavor_name       = var.mbip_flavor_name
  # security_groups   = ["RavinderSecGroup"]
  security_groups   = []
  metadata = {
    instance-id = "${var.mbip_name_prefix}-${count.index + 1}"
    local-hostname = "${var.mbip_name_prefix}-${count.index + 1}"
  }
  user_data = templatefile("${path.module}/userdata.tpl", {
    ssh_username = var.ssh_username
    ssh_password = var.ssh_password
  })

  network {
    uuid = length(var.network_port_names) == 0 ? data.openstack_networking_network_v2.admin_network.id : null
    port = length(var.network_port_names) == 0 ? null : data.openstack_networking_port_v2.network_port[count.index].id
  }

  network {
    port = openstack_networking_port_v2.external[count.index].id
  }

}
