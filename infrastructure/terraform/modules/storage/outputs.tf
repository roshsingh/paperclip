output "efs_file_system_id" {
  value = aws_efs_file_system.paperclip.id
}

output "efs_file_system_arn" {
  value = aws_efs_file_system.paperclip.arn
}

output "efs_access_point_id" {
  value = aws_efs_access_point.paperclip.id
}

output "efs_access_point_arn" {
  value = aws_efs_access_point.paperclip.arn
}
