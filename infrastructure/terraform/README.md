# Paperclip on AWS

Terraform stacks for deploying Paperclip (ECS Fargate + RDS Postgres 17 + EFS + ALB + WAF).

## Prerequisites

- AWS CLI credentials for account `872443248397`, region `us-east-1`
- Docker (for building the server image)
- Sparkmed bootstrap state backend already exists (`sparkmed-terraform-state-*`, DynamoDB lock table)

## 1. Bootstrap (once)

Creates ECR repository `paperclip/server`. Already applied if the repo exists in account `872443248397`.

```bash
cd infrastructure/terraform/bootstrap
terraform init && terraform apply
```

## 2. Build and push image (**before first ECS deployment**)

Start Docker locally. From repo root (`paperclip/`):

```bash
export ACCOUNT=872443248397
export REGION=us-east-1
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com
docker build -t paperclip/server:latest .
docker tag paperclip/server:latest ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/paperclip/server:production-latest
docker push ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/paperclip/server:production-latest
```

## 3. Deploy infrastructure

Push the image first so the ECS service can stabilize.

```bash
cd infrastructure/terraform/environments/production
export TF_VAR_db_password='YOUR_RDS_PASSWORD'
terraform init
terraform apply
```

During apply, ACM **DNS validation** will wait: add the `_xxxxx.area51.robowise.ai` CNAME output by Terraform to **Cloudflare** (DNS only or proxied).

After apply, add a **CNAME** for `area51.robowise.ai` pointing to the ALB hostname (`terraform output alb_dns_name`). Cloudflare SSL mode: **Full (strict)**.

## Outputs

- `paperclip_url` — target URL
- `alb_dns_name` — ALB DNS for Cloudflare CNAME
- `acm_certificate_validation` — temporary CNAME records for ACM
