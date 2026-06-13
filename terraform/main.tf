# ── terraform/main.tf ──────────────────────────────────
# This is the entry point for all our infrastructure
# It tells Terraform:
# - Which cloud provider to use (AWS)
# - Which region to deploy to
# - Which Terraform version is required
# ───────────────────────────────────────────────────────

terraform {
  # Minimum Terraform version required
  required_version = ">= 1.0"

  required_providers {
    # AWS provider — this is like the AWS SDK for Terraform
    # It knows how to create every AWS resource
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      # ~> 5.0 means "version 5.x but not 6.x"
      # This prevents breaking changes from major upgrades
    }
  }
}

# ── CONFIGURE AWS PROVIDER ─────────────────────────────
# Tell Terraform to use AWS and which region
provider "aws" {
  region = var.aws_region
  # var.aws_region reads from variables.tf
  # We never hardcode region — always use variables
}

# ── DATA SOURCE: CURRENT AWS ACCOUNT ───────────────────
# This asks AWS: "what account am I using?"
# We use this to build ECR image URIs later
# Format: 476639000650.dkr.ecr.us-east-1.amazonaws.com
data "aws_caller_identity" "current" {}

# ── DATA SOURCE: AVAILABLE AZs ─────────────────────────
# Asks AWS: "what availability zones exist in this region?"
# We use this to spread resources across AZs
# for high availability
data "aws_availability_zones" "available" {
  state = "available"
}