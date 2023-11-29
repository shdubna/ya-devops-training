#resource "tls_private_key" "private_key" {
#  algorithm = "ECDSA"
#}
#
#resource "tls_self_signed_cert" "self_signed_cert" {
##  key_algorithm   = tls_private_key.private_key.algorithm
#  private_key_pem = tls_private_key.private_key.private_key_pem
#
#  validity_period_hours = 720
#
#  subject {
#    common_name         = var.domain
#    organization        = "Trainings"
#    organizational_unit = "DevOps"
#    country             = "RU"
#  }
#
#  dns_names = ["${var.domain}"]
#
#  allowed_uses = ["key_encipherment", "digital_signature", "server_auth"]
#}

resource "tls_private_key" "ca" {
  algorithm   = "RSA"
  ecdsa_curve = "P256"
  rsa_bits    = "2048"
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem   = "${tls_private_key.ca.private_key_pem}"
  is_ca_certificate = true

  validity_period_hours = "740"
  allowed_uses          = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]

  subject {
    common_name  = "bingo"
    organization = "DevOps Trainings"
  }

}

resource "tls_private_key" "cert" {
  algorithm   = "RSA"
  ecdsa_curve = "P256"
  rsa_bits    = "2048"

}

resource "tls_cert_request" "cert" {
  private_key_pem = "${tls_private_key.cert.private_key_pem}"

  dns_names    = ["${var.domain}"]

  subject {
    common_name  = "${var.domain}"
    organization = "DevOps Trainings"
  }
}

resource "tls_locally_signed_cert" "cert" {
  cert_request_pem = "${tls_cert_request.cert.cert_request_pem}"

  ca_private_key_pem = "${tls_private_key.ca.private_key_pem}"
  ca_cert_pem        = "${tls_self_signed_cert.ca.cert_pem}"

  validity_period_hours = "740"
  allowed_uses          = [
    "key_encipherment",
    "digital_signature",
  ]

}