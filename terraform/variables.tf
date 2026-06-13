# ── terraform/variables.tf ─────────────────────────────
# All input variables for our infrastructure
# Think of variables like function parameters —
# they make our Terraform code reusable and flexible
# We define them here and set values in terraform.tfvars
# ───────────────────────────────────────────────────────

# ── PROJECT SETTINGS ───────────────────────────────────

variable "aws_region" {
  description = "AWS region to deploy all resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "cryptobliss"
  # This gets attached to every resource name
  # e.g. cryptobliss-api, cryptobliss-cluster
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "prod"
  # Options: dev, staging, prod
}

# ── NETWORKING ─────────────────────────────────────────

variable "vpc_cidr" {
  description = "IP range for our VPC"
  type        = string
  default     = "10.0.0.0/16"
  # 10.0.0.0/16 gives us 65,536 IP addresses
  # More than enough for our project
}

variable "public_subnet_cidrs" {
  description = "IP ranges for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  # Two subnets in different AZs for high availability
  # /24 gives 256 IPs each
}

variable "private_subnet_cidrs" {
  description = "IP ranges for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# ── ECS SETTINGS ───────────────────────────────────────

variable "container_port" {
  description = "Port our API listens on"
  type        = number
  default     = 3000
}

variable "desired_count" {
  description = "Number of containers to run"
  type        = number
  default     = 1
  # 1 container is enough for our project
  # Production apps run 2+ for high availability
}

variable "cpu" {
  description = "CPU units for the container"
  type        = number
  default     = 256
  # 256 CPU units = 0.25 vCPU
  # Enough for our small API
  # 1 vCPU = 1024 units
}

variable "memory" {
  description = "Memory in MB for the container"
  type        = number
  default     = 512
  # 512 MB RAM for our container
}

# ── S3 SETTINGS ────────────────────────────────────────

variable "s3_bucket_name" {
  description = "Name of S3 bucket for frontend files"
  type        = string
  default     = "cryptobliss-frontend"
  # S3 bucket names must be globally unique across ALL
  # AWS accounts — we'll add account ID to make it unique
}