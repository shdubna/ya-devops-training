variable "prefix" {
  description = "The prefix used for all resources in this example"
  type = string
  default = "bingo"
}

variable "zone" {
  description = "Availability zone used for all resources in this example"
  type = string
  default = "ru-central1-a"
}

variable "folder_id" {
  description = "Folder to deploy app"
  type = string
  nullable = false
}

variable "student_email" {
  description = "Email in configuration"
  type = string
  nullable = false
}

variable "pg_password" {
  description = "Password for postgres user"
  type = string
  default = "postgres"
}

variable "pg_app_database" {
  description = "Username for application user in postgres"
  type = string
  default = "bingo"
}

variable "pg_app_user" {
  description = "Username for application user in postgres"
  type = string
  default = "bingo"
}

variable "pg_app_password" {
  description = "Password for application user in postgres"
  type = string
  default = "bingo"
}

variable "listen_port" {
  description = "The port on which the application accepts requests"
  type = number
  nullable = false
}

variable "domain" {
  description = "DNS name for accessing the application"
  type = string
  nullable = false
}

variable "vpc_cidr" {
  description = "IPv4 cidr of vpc"
  type = string
  default = "10.11.0.0/24"
}

variable "ssh_key_path" {
  description = "Path to ssh public key"
  type = string
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_user" {
  description = "Username on servers"
  type = string
  default = "ubuntu"
}
