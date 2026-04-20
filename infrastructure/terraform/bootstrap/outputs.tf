output "ecr_repository_url" {
  description = "ECR repository URL for Paperclip server image"
  value       = aws_ecr_repository.server.repository_url
}

output "ecr_repository_arn" {
  value = aws_ecr_repository.server.arn
}
