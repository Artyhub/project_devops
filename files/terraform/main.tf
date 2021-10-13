terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

# Configure the OpenStack Provider

provider "openstack" {
  cloud  = "openstack" # cloud defined in cloud.yml file
}

# Variables
variable "keypair" {
  type    = string
  default = "artydesktop"   # name of keypair created 
}

variable "network" {
  type    = string
  default = "test" # default network to be used
}

variable "security_groups" {
  type    = list(string)
  default = ["default"]  # Name of default security group
}

# Data sources
## Get Image ID
data "openstack_images_image_v2" "image" {
  name        = "ubuntufocal" # Name of image to be used
  most_recent = true
}

## Get flavor id
data "openstack_compute_flavor_v2" "flavor" {
  name = "t2.micro" # flavor to be used
}

# Create an test instance
resource "openstack_compute_instance_v2" "server" {
  name            = "servertest"  #Instance name
  image_id        = data.openstack_images_image_v2.image.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = var.keypair
  security_groups = var.security_groups

  network {
    name = var.network
  }
}

# Add Floating ip

resource "openstack_networking_floatingip_v2" "fip1" {
  pool = "external"
}

resource "openstack_compute_floatingip_associate_v2" "fip1" {
  floating_ip = openstack_networking_floatingip_v2.fip1.address
  instance_id = openstack_compute_instance_v2.server.id
}

# Create an stage instance
resource "openstack_compute_instance_v2" "server2" {
  name            = "serverstage"  #Instance name
  image_id        = data.openstack_images_image_v2.image.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = var.keypair
  security_groups = var.security_groups

  network {
    name = var.network
  }
}

# Add Floating ip

resource "openstack_networking_floatingip_v2" "fip2" {
  pool = "external"
}

resource "openstack_compute_floatingip_associate_v2" "fip2" {
  floating_ip = openstack_networking_floatingip_v2.fip2.address
  instance_id = openstack_compute_instance_v2.server2.id
}

# Output VM IP Addresses
output "servertest_private_ip" {
 value = openstack_compute_instance_v2.server.access_ip_v4
}
output "servertest_floating_ip" {
 value = openstack_networking_floatingip_v2.fip1.address
}

output "serverstage_private_ip" {
 value = openstack_compute_instance_v2.server2.access_ip_v4
}
output "serverstage_floating_ip" {
 value = openstack_networking_floatingip_v2.fip2.address
}
