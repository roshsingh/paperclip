variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group attached to ECS tasks (NFS client)"
  type        = string
}

variable "posix_uid" {
  type    = number
  default = 1000
}

variable "posix_gid" {
  type    = number
  default = 1000
}

variable "tags" {
  type    = map(string)
  default = {}
}
