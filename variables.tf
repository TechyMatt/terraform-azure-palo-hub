variable "tags" {
  description = "This variable is used for passing in tags for the results. It is of type Map and must contain common_tags and compute_tags"
}

variable "networking_definitions" {
  description = "The map of all the region networks. Instructions on formatting can be found in README.md"
}

variable "panorama_server_list" {
  description = "The FQDN or IP address of the primary Panorama server"
  type        = list(any)
}

variable "deploy_palo_vms" {
  description = "If this is set to false, all resources are deployed except for the Palo Alto Virtual Machines"
  default = true
}