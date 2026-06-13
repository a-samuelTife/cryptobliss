# ── terraform/github_actions.tf ────────────────────────
# Creates an IAM user specifically for GitHub Actions
# GitHub Actions needs AWS credentials to:
# - Push Docker images to ECR
# - Deploy to ECS
# - Upload frontend files to S3
# - Invalidate CloudFront cache
# ───────────────────────────────────────────────────────

# ── IAM USER FOR GITHUB ACTIONS ────────────────────────
# A dedicated user with only the permissions
# GitHub Actions needs — nothing more
resource "aws_iam_user" "github_actions" {
  name = "${var.project_name}-github-actions"

  tags = {
    Name        = "${var.project_name}-github-actions"
    Environment = var.environment
    Purpose     = "GitHub Actions CI/CD"
  }
}

# ── IAM POLICY FOR GITHUB ACTIONS ─────────────────────
# Defines exactly what GitHub Actions is allowed to do
resource "aws_iam_user_policy" "github_actions" {
  name = "${var.project_name}-github-actions-policy"
  user = aws_iam_user.github_actions.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # ECR permissions — push Docker images
        Sid    = "ECRAccess"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      },
      {
        # ECS permissions — deploy new containers
        Sid    = "ECSAccess"
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition"
        ]
        Resource = "*"
      },
      {
        # IAM permission — needed to pass roles to ECS
        Sid      = "IAMPassRole"
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*"
      },
      {
        # S3 permissions — upload frontend files
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.frontend.arn,
          "${aws_s3_bucket.frontend.arn}/*"
        ]
      },
      {
        # CloudFront permission — clear cache after deploy
        Sid    = "CloudFrontAccess"
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation"
        ]
        Resource = "*"
      }
    ]
  })
}

# ── ACCESS KEYS ────────────────────────────────────────
# Generates AWS access keys for the GitHub Actions user
# We'll add these to GitHub repository secrets
resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}

# ── OUTPUTS FOR GITHUB SECRETS ─────────────────────────
# After terraform apply these values get printed
# Copy them into your GitHub repository secrets
output "github_actions_access_key_id" {
  description = "Add this to GitHub Secrets as AWS_ACCESS_KEY_ID"
  value       = aws_iam_access_key.github_actions.id
}

output "github_actions_secret_access_key" {
  description = "Add this to GitHub Secrets as AWS_SECRET_ACCESS_KEY"
  value       = aws_iam_access_key.github_actions.secret
  sensitive   = true
  # sensitive = true means Terraform won't print it
  # in plain text in the terminal
  # Run: terraform output github_actions_secret_access_key
  # to see it
}

output "cloudfront_distribution_id" {
  description = "Add this to GitHub Secrets as CLOUDFRONT_DISTRIBUTION_ID"
  value       = aws_cloudfront_distribution.frontend.id
}