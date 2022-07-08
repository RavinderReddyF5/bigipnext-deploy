output "admin_ipv4_addresses" {
    value = openstack_compute_instance_v2.mbip.*.access_ip_v4
}
