variable "environment" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "ecr_repository_url" {
  type = string
}

variable "image_tag" {
  type    = string
  default = "production-latest"
}

variable "cpu" {
  type    = number
  default = 1024
}

variable "memory" {
  type    = number
  default = 2048
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "ecs_secrets" {
  type = list(any)
}

variable "private_subnets" {
  type = list(string)
}

variable "ecs_security_group_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "alb_listener_arn" {
  type = string
}

variable "efs_file_system_id" {
  type = string
}

variable "efs_access_point_id" {
  type = string
}

variable "container_port" {
  type    = number
  default = 3100
}

variable "paperclip_public_url" {
  type        = string
  description = "Public HTTPS URL (must match Cloudflare hostname)"
}

variable "paperclip_allowed_hostnames" {
  type        = string
  description = "Comma-separated hostnames for auth/origin checks (e.g. area51.robowise.ai)"
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
