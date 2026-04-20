variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}

variable "hostname" {
  description = "FQDN for Paperclip (e.g. area51.robowise.ai)"
  type        = string
}

variable "container_port" {
  type    = number
  default = 3100
}

variable "elb_account_id" {
  description = "AWS ELB account ID for ALB log delivery (us-east-1)"
  type        = string
  default     = "127311923021"
}

variable "tags" {
  type    = map(string)
  default = {}
}
