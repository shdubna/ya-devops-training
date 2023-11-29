resource "yandex_vpc_network" "vpc" {
  name      = "${var.prefix}-vpc"
  folder_id = "${var.folder_id}"
}

resource "yandex_vpc_subnet" "subnet" {
  zone           = "${var.zone}"
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = ["${var.vpc_cidr}"]
  name           = "${var.prefix}-subnet"
  folder_id      = "${var.folder_id}"
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "${var.prefix}-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name       = "${var.prefix}-route-table"
  network_id = yandex_vpc_network.vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

#resource "yandex_vpc_security_group" "sg" {
#  name        = "${var.prefix}-sg"
#  network_id  = "${yandex_vpc_network.vpc.id}"
#
#  ingress {
#    protocol       = "ANY"
#    v4_cidr_blocks = ["${var.vpc_cidr}"]
#  }
#
#  ingress {
#    protocol          = "tcp"
#    predefined_target = "loadbalancer_healthchecks"
#    port              = 80
#  }
#
#  ingress {
#    protocol          = "tcp"
#    v4_cidr_blocks = ["0.0.0.0/0"]
#    port              = 80
#  }
#
#  ingress {
#    protocol          = "ANY"
#    v4_cidr_blocks = ["0.0.0.0/0"]
#    port              = 443
#  }
#
#  egress {
#    protocol       = "ANY"
#    v4_cidr_blocks = ["0.0.0.0/0"]
#  }
#}

resource "yandex_vpc_default_security_group" "default-sg" {
  network_id  = "${yandex_vpc_network.vpc.id}"

  ingress {
    protocol       = "ANY"
    v4_cidr_blocks = ["${var.vpc_cidr}"]
  }

#  ingress {
#    protocol          = "tcp"
#    predefined_target = "loadbalancer_healthchecks"
#    port              = 80
#  }

  ingress {
    protocol          = "tcp"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port              = 80
  }

  ingress {
    protocol          = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port              = 443
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
