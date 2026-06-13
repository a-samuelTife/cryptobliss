# ── terraform/ecr.tf ───────────────────────────────────
# Creates the ECR repository where our Docker images
# will be stored after GitHub Actions builds them
# ───────────────────────────────────────────────────────

resource "aws_ecr_repository" "api" {
  name                 = "${var.project_name}-api"
  image_tag_mutability = "MUTABLE"
  # MUTABLE means we can overwrite the "latest" tag
  # each time we push a new image
  # IMMUTABLE would prevent overwriting tags

  # Scan images for security vulnerabilities on push
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-api"
    Environment = var.environment
  }
}

# ── ECR LIFECYCLE POLICY ───────────────────────────────
# Automatically delete old images to save storage costs
# Keeps only the 5 most recent images
# Old images pile up fast without this
resource "aws_ecr_lifecycle_policy" "api" {
  repository = aws_ecr_repository.api.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images only"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}