/*
Copyright 2019 The KubeOne Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

resource "openstack_networking_port_v2" "bastion" {
  name               = "${var.cluster_name}-bastion"
  admin_state_up     = "true"
  network_id         = openstack_networking_network_v2.network.id
  security_group_ids = [openstack_networking_secgroup_v2.securitygroup.id]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }
}

resource "openstack_compute_instance_v2" "bastion" {
  name            = "${var.cluster_name}-bastion"
  image_name      = "Ubuntu-22.04-Cloudimage.qcow2"
  flavor_name     = var.bastion_flavor
  key_pair        = openstack_compute_keypair_v2.deployer.name
  security_groups = [openstack_networking_secgroup_v2.securitygroup.name]
  config_drive    = var.config_drive

  user_data = var.disable_auto_update ? templatefile("./userdata_flatcar_upgrades.json", {
    ssh_key = trimspace(file(pathexpand(var.ssh_public_key_file)))
  }) : null

 block_device {
    uuid                  = "cc17ddfe-6c70-4dfa-8b37-3aa232dc0de2"
    source_type           = "image"
    volume_size           = 20
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.bastion.id
  }
  
}

resource "openstack_networking_floatingip_v2" "bastion" {
  pool = var.external_network_name
}

resource "openstack_networking_floatingip_associate_v2" "bastion" {
  floating_ip = openstack_networking_floatingip_v2.bastion.address
  port_id     = openstack_networking_port_v2.bastion.id
}
