output "admin_ipv4_addresses" {
    value = module.mbip.admin_ipv4_addresses
}

# output "internal_ipv4_addresses" {
#     value = module.mbip.internal_ipv4_addresses
# }
output "external_ipv4_addresses" {
    value = module.mbip.external_ipv4_addresses
}

# output "ha_data_plane_ipv4_addresses" {
#     value = module.mbip.ha_data_plane_ipv4_addresses
# }

output "admin_instance_image" {
    value = module.mbip.admin_instance_image
}