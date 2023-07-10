resource "yandex_compute_disk" "volume" {
  name     = "disk-${count.index+1}"
  type     = "network-hdd"
  zone     = var.default_zone
  size     = 1
  count    = 3
}

data "yandex_compute_image" "ubuntu2" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "storage" {
  name        = "netology-develop-storage"
  platform_id = "standard-v3"
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.volume[*]
    content {
      disk_id = lookup(secondary_disk.value, "id")
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.public_key}"
  }

}
