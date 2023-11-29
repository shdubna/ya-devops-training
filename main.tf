terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  service_account_key_file = "./tf_key.json"
  folder_id                = var.folder_id
  zone                     = var.zone
}

locals {
  logs_dir = substr(sha1(var.student_email), 0, 10)
  prt = base64sha512(var.student_email)
  service-accounts = toset([
    "bingo-sa",
    "pg-sa",
    "bingo-ig-sa",
  ])
  bingo-sa-roles = toset([
    "container-registry.images.puller",
#    "monitoring.editor",
  ])
  pg-sa-roles = toset([
    "container-registry.images.puller",
#    "monitoring.editor",
  ])
  bingo-ig-sa-roles = toset([
    "compute.editor",
    "iam.serviceAccounts.user",
    "load-balancer.admin",
    "vpc.publicAdmin",
    "vpc.user",
  ])
}

data "yandex_compute_image" "coi" {
  family = "container-optimized-image"
}
