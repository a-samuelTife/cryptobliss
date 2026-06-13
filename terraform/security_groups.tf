# ── terraform/security_groups.tf ───────────────────────
# Security Groups are like firewalls for AWS resources
# They control what traffic is ALLOWED in and out
# Every resource needs a security group
#
# Two rules types:
# ingress = incoming traffic (who can reach us)
# egress  = outgoing traffic (where we can go)
# ───────────────────────────────────────────────────────

# ── LOAD BALANCER SECURITY GROUP ───────────────────────
# The Load Balancer sits in front of our API
# It needs to accept HTTP traffic from the internet
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  # Allow HTTP traffic from anywhere on the internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from internet"
  }

  # Allow HTTPS traffic from anywhere on the internet
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from internet"
  }

  # Allow ALL outbound traffic
  # The ALB needs to forward requests to ECS containers
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    # -1 means ALL protocols
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-alb-sg"
    Environment = var.environment
  }
}

# ── ECS SECURITY GROUP ──────────────────────────────────
# Our API containers run behind the Load Balancer
# They should ONLY accept traffic from the ALB
# not directly from the internet — more secure
resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-ecs-sg"
  description = "Security group for ECS containers"
  vpc_id      = aws_vpc.main.id

  # Only allow traffic from the Load Balancer
  # on our API port (3000)
  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    # security_groups = only allow from this SG
    # Much more secure than allowing from 0.0.0.0/0
    description     = "Allow traffic from ALB only"
  }

  # Allow ALL outbound traffic
  # Containers need to reach:
  # - AWS Comprehend (for sentiment analysis)
  # - AWS DynamoDB (for storing reviews)
  # - AWS ECR (to pull the Docker image)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound for AWS services"
  }

  tags = {
    Name        = "${var.project_name}-ecs-sg"
    Environment = var.environment
  }
}