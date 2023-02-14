terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"


  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "stebacket"
    region     = "ru-central1"
    key        = "./terraform.tfstate"
    access_key = "YCAJEECb5yXWsbqvhRg-xNtLK"
    secret_key = "YCMjwuIA_h4YhkIF_JT38DuXZWCimZzXNnErJzG2"

    skip_region_validation      = true
    skip_credentials_validation = true
  }

}

provider "yandex" {
  token     = var.token     #переменная берется из bashrc
  cloud_id  = var.cloud_id  #переменная берется из bashrc
  folder_id = var.folder_id #переменная берется из bashrc
  zone      = "ru-central1-a"
}


data "yandex_compute_image" "ubuntu_image" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "vm-test1" {
  name = "test1"

  resources {
    cores  = var.CPU_test
    memory = var.memory_test
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_image.id
      size     = var.disk_test
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_terraform.id
    nat       = true
  }

  metadata = {
    user-data = "${file("./user.txt")}"
  }

  provisioner "remote-exec" {
    inline     = ["sudo apt-get update -y"]
    on_failure = continue
    connection {
      user        = "admin"
      private_key = file(var.ssh_key_private)
      host        = self.network_interface.0.nat_ip_address
    }
  }


  provisioner "local-exec" {
    command = "ansible-playbook -u admin -i '${self.network_interface.0.nat_ip_address}, ' --private-key ${var.ssh_key_private} provision.yml"
  }

  timeouts {
    create = "10m"
  }

}

resource "yandex_vpc_network" "network_terraform" {
  name = "net_terraform"
}

resource "yandex_vpc_subnet" "subnet_terraform" {
  name           = "sub_terraform"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network_terraform.id
  v4_cidr_blocks = ["192.168.15.0/24"]
}
