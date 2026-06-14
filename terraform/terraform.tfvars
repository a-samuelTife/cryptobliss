# ── terraform/terraform.tfvars ─────────────────────────
# Actual values for our variables
# This file is like filling in a form —
# variables.tf defines the fields,
# terraform.tfvars fills them in
#
# ⚠️ This file is in .gitignore — never push it to
# GitHub if it contains secrets or account details
# ───────────────────────────────────────────────────────

aws_region   = "us-east-1"
project_name = "cryptobliss"
environment  = "prod"

# Networking
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

# ECS
container_port = 3000
desired_count  = 1
cpu            = 256
memory         = 512

# S3 — must be globally unique
s3_bucket_name = "cryptobliss-frontend-476639000650"