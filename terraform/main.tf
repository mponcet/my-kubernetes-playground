terraform {
 required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.3"
    }
  }
}

provider "libvirt" {
    uri = "qemu:///system"
}

resource "libvirt_volume" "ubuntu_cloudimg" {
  name	 = "ubuntu-20.04-server-cloudimg-amd64.img"
  source = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img"
}

resource "libvirt_volume" "k8s_master_volume" {
  name           = "k8s-master.qcow2"
  base_volume_id = libvirt_volume.ubuntu_cloudimg.id
  size           = var.disk_size
}

resource "libvirt_volume" "k8s_worker_volume" {
  count          = var.k8s_worker_count
  name           = "k8s-worker-${count.index+1}.qcow2"
  base_volume_id = libvirt_volume.ubuntu_cloudimg.id
  size           = var.disk_size
}

data "template_file" "user_data_k8s_master" {
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    hostname = "k8s-master"
  }
}

data "template_file" "user_data_k8s_worker" {
  count    = var.k8s_worker_count
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    hostname = "k8s-worker-${count.index+1}"
  }
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.cfg")
}

resource "libvirt_cloudinit_disk" "k8s_master_cloud_init" {
  name           = "k8s-master-cloud-init.iso"
  user_data      = data.template_file.user_data_k8s_master.rendered
  network_config = data.template_file.network_config.rendered
  pool           = "default"
}
resource "libvirt_cloudinit_disk" "k8s_worker_cloud_init" {
  count          = var.k8s_worker_count
  name           = "k8s-worker-${count.index+1}-cloud-init.iso"
  user_data      = data.template_file.user_data_k8s_worker[count.index].rendered
  network_config = data.template_file.network_config.rendered
  pool           = "default"
}

resource "libvirt_domain" "k8s_master" {
  name   = "k8s-master"
  memory = "512"
  vcpu   = var.vcpu

  cloudinit = libvirt_cloudinit_disk.k8s_master_cloud_init.id

  network_interface {
    network_name   = "default"
    hostname       = "k8s-master.local"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.k8s_master_volume.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "k8s_worker" {
  count  = var.k8s_worker_count
  name   = "k8s-worker-${count.index + 1}"
  memory = "512"
  vcpu   = var.vcpu

  cloudinit = libvirt_cloudinit_disk.k8s_worker_cloud_init[count.index].id

  network_interface {
    network_name   = "default"
    hostname       = "k8s-worker-${count.index+1}.local"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.k8s_worker_volume[count.index].id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
