variable "tags" {}
variable "network_details" {}
variable "resource_group_name" {}
variable "location" {}
variable "nva_details" {}

variable "vm_sku" {}

variable "palo_local_user" {}

variable "palo_local_password" {}

variable "panorama_server_list" {}

variable "untrust_pip_prefixes" {
}

variable "deploy_palo_vms" {
  default = true
}

variable "interface_public_ip" {
  description = "Optional: Specifies whether or not to attach public IPs to the untrust interface"
  default = true
}