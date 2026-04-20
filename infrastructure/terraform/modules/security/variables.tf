variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "secret_arns" {
  type = list(string)
}

variable "container_port" {
  type    = number
  default = 3100
}

variable "waf_rate_limit" {
  type    = number
  default = 2000
}

variable "tags" {
  type    = map(string)
  default = {}
}
