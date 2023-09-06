terraform {
  required_version = "> 1.2.4"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 1.47.0"
    }
  }
}

data "openstack_networking_network_v2" "admin_network" {
  name = var.admin_network_name
}

data "openstack_networking_network_v2" "external_network" {
  name = var.external_network_name
}

data "openstack_networking_subnet_v2" "external_network_subnet" {
  name       = var.external_network_subnet_name
  network_id = data.openstack_networking_network_v2.external_network.id
}

data "openstack_networking_port_v2" "network_port" {
  count = length(var.network_port_names)
  name  = var.network_port_names[count.index]
}

resource "openstack_networking_port_v2" "external" {
  count                 = length(var.external_ip_addresses)
  name                  = format("%s-external-%s", var.mbip_name_prefix, count.index)
  network_id            = data.openstack_networking_network_v2.external_network.id
  admin_state_up        = true
  port_security_enabled = false
  fixed_ip {
    subnet_id  = data.openstack_networking_subnet_v2.external_network_subnet.id
    ip_address = var.external_ip_addresses[count.index]
  }
}

resource "openstack_compute_instance_v2" "mbip" {
  count             = length(openstack_networking_port_v2.external.*.id)
  availability_zone = var.availability_zone
  region            = ""
  name              = format("%s-ve", var.mbip_name_prefix)
  image_id          = var.mbip_image_name
  flavor_name       = var.mbip_flavor_name
  security_groups   = []
  metadata = {
    instance-id    = format("%s-ve", var.mbip_name_prefix)
    local-hostname = format("%s-ve", var.mbip_name_prefix)
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
