output "admin_ipv4_addresses" {
    value = openstack_compute_instance_v2.mbip.*.access_ip_v4
}

# output "internal_ipv4_addresses" {
#     value = flatten(openstack_networking_port_v2.internal[*].fixed_ip[*].ip_address)
# }

output "external_ipv4_addresses" {
    value = flatten(openstack_networking_port_v2.external[*].fixed_ip[*].ip_address)
}

# output "ha_data_plane_ipv4_addresses" {
#     value = var.ha_data_plane_network_name == "" ? [] : flatten(openstack_networking_port_v2.ha_data_plane[*].fixed_ip[*].ip_address)
# }
output "admin_instance_image" {
    value = element(concat(openstack_compute_instance_v2.mbip[*].image_name, tolist([null])), 0)
}
