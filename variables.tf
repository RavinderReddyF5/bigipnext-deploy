variable "admin_network_name" {
  description = "The public network name in VIO."
}
variable "auth_url" {
  description = "The Identity authentication URL"
  default = "https://vio-sea.pdsea.f5net.com:5000/v3"
}
variable "availability_zone" {
  description = "The availability zone in which to create the server"
  default = "nova"
}
variable "mbip_name_prefix" {
  description = "Name prefix for mbip instances"
}
variable "mbip_image_name" {
  description = "The image name in VIO."
  default = "latest"
}
variable "mbip_flavor_name" {
  description = "The flavor preset in VIO."
}
variable "num_mbips" {
  description = "Number of mbip instances to create"
}
variable "password" {
  description = "The Password to login with."
  sensitive = true
}
variable "user_name" {
  description = "The Username to login with"
  sensitive = true
}
variable "tenant_name" {
  description = "The Name of the Tenant or Project to login with."
}
