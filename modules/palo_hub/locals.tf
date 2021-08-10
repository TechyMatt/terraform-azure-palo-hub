locals {
  networking_definitions = var.networking_definitions[var.location]

  region_shortcode = var.networking_definitions[var.location].region_abbreviation
}