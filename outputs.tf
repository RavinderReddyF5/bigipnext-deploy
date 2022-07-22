output "admin_ipv4_addresses" {
    value = openstack_compute_instance_v2.mbip.*.access_ip_v4
}
output "internal_ipv4_addresses" {
    value = flatten(openstack_networking_port_v2.internal[*].fixed_ip[*].ip_address)
}
output "external_ipv4_addresses" {
    value = flatten(openstack_networking_port_v2.external[*].fixed_ip[*].ip_address)
}
