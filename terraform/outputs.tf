# ── terraform/outputs.tf ───────────────────────────────
# Outputs are values Terraform prints after deployment
# Think of them like return values from a function
# They tell you the important URLs and IDs after
# everything is created
# ───────────────────────────────────────────────────────

# ── FRONTEND OUTPUTS ───────────────────────────────────

output "cloudfront_url" {
  description = "URL of the CloudFront distribution"
  value       = "https://${aws_cloudfront_distribution.frontend.domain_name}"
  # This is the URL you share with people to visit
  # your CryptoBliss website
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting frontend"
  value       = aws_s3_bucket.frontend.id
}

# ── BACKEND OUTPUTS ────────────────────────────────────

output "ecr_repository_url" {
  description = "ECR repository URL for Docker images"
  value       = aws_ecr_repository.api.repository_url
  # Format: 476639000650.dkr.ecr.us-east-1.amazonaws.com/cryptobliss-api
  # Jenkins/GitHub Actions uses this to push images
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.api.name
}

output "api_url" {
  description = "Public URL of the API"
  value       = "http://${aws_lb.api.dns_name}"
  # This is the Load Balancer URL for our API
  # We'll use this in the frontend to make API calls
}

# ── ECR IMAGE URI ──────────────────────────────────────

output "ecr_image_uri" {
  description = "Full ECR image URI for GitHub Actions"
  value = "${aws_ecr_repository.api.repository_url}:latest"
}