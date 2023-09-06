variable "auth_url" {
  description = "The openstack identity authentication URL."
  default     = "https://vio-sea.pdsea.f5net.com:5000/v3"
}
variable "username" {
  description = "The username to log in with."
  sensitive   = true
}
variable "password" {
  description = "The password to log in with."
  sensitive   = true
}
variable "tenant_name" {
  description = "The name of the tenant to create BIG-IP Next instances in."
}
variable "availability_zone" {
  description = "The availability zone to create BIG-IP Next instances in."
  default     = "nova"
}

variable "mbip_flavor_name" {
  description = "The openstack flavor to use when creating the BIG-IP Next instances."
}
variable "admin_network_name" {
  description = "The name of the openstack network to use as the management network."
  default     = ""
}
variable "network_port_names" {
  description = "List of network port names to attach to BIG-IP Next instances for static IP addresses."
  type        = list(string)
  default     = []
}
variable "internal_network_name" {
  description = "The name of the openstack network to use as the BIG-IP Next internal network."
}
variable "internal_network_subnet_name" {
  description = "The subnet to use for the BIG-IP Next internal network."
}
variable "internal_ip_addresses" {
  description = "List of IP addresses to configure on the BIG-IP Next internal network."
  type        = list(string)
  default     = []
}
variable "external_network_name" {
  description = "The name of the openstack network to use as the BIG-IP Next external network."
}
variable "external_network_subnet_name" {
  description = "The subnet to use for the BIG-IP Next external network."
}
variable "external_ip_addresses" {
  description = "List of IP addresses to configure on the BIG-IP Next external network."
  type        = list(string)
  default     = []
}
variable "ha_data_plane_network_name" {
  description = "The name of the openstack network to use as the BIG-IP Next HA data plane network."
  default     = ""
}
variable "ha_data_plane_network_subnet_name" {
  description = "The subnet to use for the BIG-IP Next HA data plane network."
  default     = ""
}
variable "ha_data_plane_ip_addresses" {
  description = "List of IP addresses to configure on the BIG-IP Next HA data plane network."
  type        = list(string)
  default     = []
}
variable "mbip_name_prefix" {
  description = "The name prefix for BIG-IP Next instances."
}
variable "mbip_image_name" {
  description = "The openstack image name to use for creating BIG-IP Next instances or latest."
  default     = "latest"
}
variable "num_mbips" {
  description = "Number of BIG-IP Next instances to create."
  default     = 1
}
variable "ssh_username" {
  description = "The username to configure via cloud-init for ssh access to the VM."
  default     = "f5debug"
}
variable "ssh_password" {
  description = "The hashed password to configure via cloud-init for ssh access to the VM."
  default     = "Welcome123!"
}