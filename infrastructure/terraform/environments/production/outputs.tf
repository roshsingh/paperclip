output "paperclip_url" {
  description = "Public URL after Cloudflare CNAME points to the ALB"
  value       = local.paperclip_public_url
}

output "alb_dns_name" {
  description = "Create a CNAME in Cloudflare: hostname -> this value (proxied OK)"
  value       = module.loadbalancer.alb_dns_name
}

output "acm_certificate_validation" {
  description = "Add these CNAME records in Cloudflare while terraform apply is waiting on certificate validation"
  value = [
    for dvo in tolist(module.loadbalancer.acm_domain_validation_options) : {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  ]
}

output "ecs_cluster_name" {
  value = module.compute.cluster_name
}

output "ecs_service_name" {
  value = module.compute.service_name
}

output "ecr_repository_url" {
  value = data.aws_ecr_repository.server.repository_url
}

output "db_endpoint" {
  value     = module.database.endpoint
  sensitive = true
}
