variable "admin_network_name" {
  description = "The public network name in VIO."
  default = ""
}
variable "internal_network_name" {
  description = "The network name in VIO to use for the internal network."
  default = ""
}
variable "external_network_name" {
  description = "The network name in VIO to use for the external network."
  default = ""
}
variable "network_port_name" {
  description = "List of network port name to use"
  type = list(string)
  default = []
}
variable "mbip_name_prefix" {
  description = "Name prefix for mbip instances"
}
variable "mbip_release" {
  description = "The mbip release to get the latest image for"
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
variable "tenant_name" {
  description = "The Name of the Tenant or Project to login with."
}
variable "user_name" {
  description = "The Username to login with"
  sensitive = true
}
variable "password" {
  description = "The Password to login with."
  sensitive = true
}
variable "create_cluster_ip" {
  description = "Flag to indicate whether or not to create a new cluster ip in VIO."
  default = "no"
}
variable "mbip_ha_pool_name" {
  description = "The Name of Pool to be used to create Cluster IP in VIO."
  default = "k8s-ext"
}
