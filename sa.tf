resource "yandex_iam_service_account" "service-accounts" {
  for_each = local.service-accounts
  name     = "${var.folder_id}-${var.prefix}-${each.key}"
}

resource "yandex_resourcemanager_folder_iam_member" "pg-roles" {
  for_each  = local.pg-sa-roles
  folder_id = var.folder_id
  member    = "serviceAccount:${yandex_iam_service_account.service-accounts["pg-sa"].id}"
  role      = each.key
}

resource "yandex_resourcemanager_folder_iam_member" "bingo-roles" {
  for_each  = local.bingo-sa-roles
  folder_id = var.folder_id
  member    = "serviceAccount:${yandex_iam_service_account.service-accounts["bingo-sa"].id}"
  role      = each.key
}

resource "yandex_resourcemanager_folder_iam_member" "bingo-ig-roles" {
  for_each  = local.bingo-ig-sa-roles
  folder_id = var.folder_id
  member    = "serviceAccount:${yandex_iam_service_account.service-accounts["bingo-ig-sa"].id}"
  role      = each.key
}