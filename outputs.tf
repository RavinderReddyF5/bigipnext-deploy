output "admin_ipv4_addresses" {
    value = openstack_compute_instance_v2.mbip.*.access_ip_v4
}
output "cluster_ip_address" {
    value = openstack_networking_floatingip_v2.cluster_ip.*.address
}
