resource "yandex_compute_instance" "postgres" {

  name                      = "${var.prefix}-postgres"
  platform_id               = "standard-v2"
  zone                      = "${var.zone}"

  service_account_id = yandex_iam_service_account.service-accounts["bingo-sa"].id

  resources {
    cores  = "2"
    memory = "2"
  }

  boot_disk {
    initialize_params {
      type     = "network-hdd"
      size     = "30"
      image_id = data.yandex_compute_image.coi.id
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet.id
    nat                = false
    security_group_ids = ["${yandex_vpc_default_security_group.default-sg.id}"]
  }

  metadata = {
    docker-compose = templatefile(
      "${path.module}/postgres/docker-compose.yaml",
      {
        registry_id     = "${yandex_container_registry.registry.id}"
        pg_password     = "${var.pg_password}",
        pg_app_database = "${var.pg_app_database}"
        pg_app_user     = "${var.pg_app_user}",
        pg_app_password = "${var.pg_app_password}"
      }
    )
    user-data = templatefile(
      "${path.module}/postgres/cloud-config.yaml",
      {
        student_email   = "${var.student_email}"
        pg_app_database = "${var.pg_app_database}"
        pg_app_user     = "${var.pg_app_user}"
        pg_app_password = "${var.pg_app_password}"
      }
    )
    ssh-keys  = "${var.ssh_user}:${file(var.ssh_key_path)}"
  }
}
