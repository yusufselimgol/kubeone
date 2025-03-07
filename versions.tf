terraform {
  required_version = ">= 1.0.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.52.0"
    }
  }
}

provider "openstack" {
  use_octavia = true
  user_name   = "Cloud-Solutions"
  tenant_name = "Cloud-Solutions"
  password   = "#######"
  auth_url   = "https://eu-southeast-1b.api.dt.net.tr:5000/v3"
  region     = "RegionOne"
  domain_name = "Cloud-Solutions"
}
