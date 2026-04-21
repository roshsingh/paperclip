variable "environment" {
  type    = string
  default = "production"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "hostname" {
  description = "Public hostname for Paperclip (ACM + PAPERCLIP_API_URL)"
  type        = string
  default     = "area51.robowise.ai"
}

variable "container_port" {
  type    = number
  default = 3100
}

variable "db_password" {
  type        = string
  description = "RDS postgres password"
  sensitive   = true
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.small"
}

variable "db_storage" {
  type    = number
  default = 20
}

variable "db_max_storage" {
  type    = number
  default = 100
}

variable "db_backup_retention" {
  type    = number
  default = 7
}

variable "db_multi_az" {
  type    = bool
  default = false
}

variable "db_deletion_protection" {
  type    = bool
  default = false
}

variable "db_engine_version" {
  type    = string
  default = "17.2"
}

variable "db_performance_insights" {
  type    = bool
  default = false
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "ecs_cpu" {
  type    = number
  default = 1024
}

variable "ecs_memory" {
  type    = number
  default = 4096
}

variable "ecs_desired_count" {
  type    = number
  default = 1
}

variable "ecs_image_tag" {
  description = "Docker tag pushed to ECR"
  type        = string
  default     = "production-latest"
}

variable "alarm_email" {
  type    = string
  default = ""
}
