resource "yandex_container_registry" "registry" {
  name = "${var.prefix}-registry"
}
