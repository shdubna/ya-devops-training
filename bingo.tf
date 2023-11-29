resource "yandex_compute_instance_group" "bingo-ig" {

  depends_on = [
    yandex_resourcemanager_folder_iam_member.bingo-ig-roles
  ]
  name               = "${var.prefix}-bingo-ig"
  service_account_id = yandex_iam_service_account.service-accounts["bingo-ig-sa"].id
  allocation_policy {
    zones = ["${var.zone}"]
  }

  deploy_policy {
    max_unavailable = 1
    max_creating    = 2
    max_expansion   = 2
    max_deleting    = 2
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }

  instance_template {
    platform_id        = "standard-v2"
    service_account_id = yandex_iam_service_account.service-accounts["pg-sa"].id

    resources {
      cores         = 2
      memory        = 2
    }

    scheduling_policy {
      preemptible = true
    }

    network_interface {
      network_id         = yandex_vpc_network.vpc.id
      subnet_ids         = ["${yandex_vpc_subnet.subnet.id}"]
      nat                = false
      security_group_ids = ["${yandex_vpc_default_security_group.default-sg.id}"]
    }

    boot_disk {
      initialize_params {
        type     = "network-hdd"
        size     = "30"
        image_id = data.yandex_compute_image.coi.id
      }
    }

    metadata = {
      docker-compose = templatefile(
        "${path.module}/bingo/docker-compose.yaml",
        {
          registry_id = "${yandex_container_registry.registry.id}"
          logs_dir    = "${local.logs_dir}"
          listen_port = "${var.listen_port}"

        }
      )
      user-data = templatefile(
        "${path.module}/bingo/cloud-config.yaml",
        {
          postgres_host   = "${yandex_compute_instance.postgres.id}"
          student_email   = "${var.student_email}"
          pg_app_database = "${var.pg_app_database}"
          pg_app_user     = "${var.pg_app_user}"
          pg_app_password = "${var.pg_app_password}"
          listen_port     = "${var.listen_port}"
          private_key     = "${tls_private_key.cert.private_key_pem}"
          cert            = "${tls_locally_signed_cert.cert.cert_pem}"
          domain          = "${var.domain}"
        }
      )
      ssh-keys  = "${var.ssh_user}:${file(var.ssh_key_path)}"
    }
  }

  load_balancer {
    target_group_name = "${var.prefix}-bingo"
  }
}

resource "yandex_lb_network_load_balancer" "lb-bingo" {
  name = "${var.prefix}-bingo"

  listener {
    name        = "http-listener"
    port        = 80
    target_port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  listener {
    name        = "https-listener"
    port        = 443
    target_port = 443
    external_address_spec {
      ip_version = "ipv4"
    }
  }

# Uncomment to enable http3
#  listener {
#    name        = "quick-listener"
#    port        = 443
#    target_port = 443
#    protocol    = "udp"
#    external_address_spec {
#      ip_version = "ipv4"
#    }
#  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.bingo-ig.load_balancer[0].target_group_id

    healthcheck {
      name = "ping"
      http_options {
        port = 80
        path = "/ping"
      }
    }
  }
}
