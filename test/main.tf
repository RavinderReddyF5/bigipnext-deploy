terraform {
  backend "local" {}
}

module "mbip" {
  source             = "./.."
  user_name          = var.user_name
  tenant_name        = var.tenant_name
  password           = var.password
  num_mbips          = var.num_mbips
  mbip_name_prefix   = var.mbip_name_prefix
  mbip_image_name    = var.mbip_image_name
  mbip_flavor_name   = var.mbip_flavor_name
  admin_network_name = var.admin_network_name
}
