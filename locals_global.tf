locals {
  common_tags = {
    environment = var.environment
    project     = var.project
    Owner       = var.owner
  }
  compute_tags = {
    network = var.network_tier
    support = var.support_team
  }
}

