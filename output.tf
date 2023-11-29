output "container_registry_id" {
  value = yandex_container_registry.registry.id
}

output "load_balancer_ip" {
  value = [for j in [for i in yandex_lb_network_load_balancer.lb-bingo.listener : i][0].external_address_spec : j][0].address
}


