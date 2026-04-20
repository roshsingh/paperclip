variable "environment" {
  type = string
}

variable "alarm_email" {
  type    = string
  default = ""
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "rds_instance_id" {
  type = string
}

variable "alb_arn_suffix" {
  type = string
}

variable "target_group_arn_suffix" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
