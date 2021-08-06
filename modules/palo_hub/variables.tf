variable "region_shortcode" {}
variable "common_tags" {}

variable "palo_vm_sku" {
  default = "Standard_DS3_v2"
}

variable "palo_local_user" {
  default = "adminusr"
}

variable "palo_local_password" {
  default = "TempLocalpa$$phras3"
}

variable "networking_definitions" {

}

variable "location" {}

variable "panorama_server_list" {}

variable "resource_groups" {}