resource "aws_security_group" "efs" {
  name        = "paperclip-${var.environment}-efs-sg"
  description = "NFS access to EFS for Paperclip data"
  vpc_id      = var.vpc_id

  ingress {
    description     = "NFS from ECS tasks"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_efs_file_system" "paperclip" {
  creation_token   = "paperclip-${var.environment}-data"
  encrypted        = true
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  tags = merge(var.tags, { Name = "paperclip-${var.environment}-efs" })
}

resource "aws_efs_mount_target" "paperclip" {
  count = length(var.private_subnet_ids)

  file_system_id  = aws_efs_file_system.paperclip.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_access_point" "paperclip" {
  file_system_id = aws_efs_file_system.paperclip.id

  posix_user {
    gid = var.posix_gid
    uid = var.posix_uid
  }

  root_directory {
    path = "/paperclip"
    creation_info {
      owner_gid   = var.posix_gid
      owner_uid   = var.posix_uid
      permissions = "755"
    }
  }

  tags = var.tags
}
