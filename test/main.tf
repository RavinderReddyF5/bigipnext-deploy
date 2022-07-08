terraform {
  backend "local" {}
}

module "mbip" {
  source                = "./.."
  username              = var.username
  password              = var.password
  tenant_name           = var.tenant_name
  mbip_flavor_name      = var.mbip_flavor_name
  admin_network_name    = var.admin_network_name
  network_port_names    = var.network_port_names
  internal_network_name = var.internal_network_name
  external_network_name = var.external_network_name
  mbip_name_prefix      = var.mbip_name_prefix
  mbip_image_name       = var.mbip_image_name
  mbip_release          = var.mbip_release
  num_mbips             = var.num_mbips
}
