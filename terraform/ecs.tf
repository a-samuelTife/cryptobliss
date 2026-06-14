# ── terraform/ecs.tf ───────────────────────────────────
# Creates everything needed to run our API on
# ECS Fargate:
# - IAM roles (permissions)
# - ECS Cluster
# - Task Definition (how to run the container)
# - Application Load Balancer (receives traffic)
# - ECS Service (keeps container running)

# IAM ROLE FOR ECS TASK EXECUTION 
# ECS needs permission to:
# - Pull Docker images from ECR
# - Write logs to CloudWatch
# This role gives ECS those permissions
resource "aws_iam_role" "ecs_execution" {
  name = "${var.project_name}-ecs-execution-role"

  # Trust policy — who can assume this role
  # ecs-tasks.amazonaws.com = ECS task runner
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project_name}-ecs-execution-role"
    Environment = var.environment
  }
}

# Attach AWS managed policy for ECS task execution
# This policy allows ECR pulls and CloudWatch logging
resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM ROLE FOR ECS TASK
# This role is for the APPLICATION itself
# Our API needs permission to call:
# - Amazon Comprehend (sentiment analysis)
# - DynamoDB (store reviews)
resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project_name}-ecs-task-role"
    Environment = var.environment
  }
}

# Custom policy giving our app access to
# Comprehend and DynamoDB
resource "aws_iam_role_policy" "ecs_task" {
  name = "${var.project_name}-ecs-task-policy"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # Allow calling Amazon Comprehend
        Effect = "Allow"
        Action = [
          "comprehend:DetectSentiment",
          "comprehend:DetectDominantLanguage"
        ]
        Resource = "*"
      },
      {
        # Allow reading and writing to DynamoDB tables
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ]
        Resource = [
          "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/cryptobliss-reviews",
          "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/cryptobliss-feedback"
        ]
      }
    ]
  })
}

# ECS CLUSTER
# A cluster is a logical grouping of ECS services
# Think of it like a building that contains apartments
# The cluster is the building, services are apartments
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  # Enable CloudWatch Container Insights
  # Gives you detailed monitoring metrics
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.project_name}-cluster"
    Environment = var.environment
  }
}

# CLOUDWATCH LOG GROUP 
# Where our container logs will be stored
# Every console.log() in our API appears here
resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${var.project_name}-api"
  retention_in_days = 7
  # Keep logs for 7 days then auto-delete
  # Saves money on log storage

  tags = {
    Name        = "${var.project_name}-logs"
    Environment = var.environment
  }
}

# ECS TASK DEFINITION
# Describes how to run our container:
# - Which Docker image to use
# - How much CPU and memory
# - Which ports to open
# - Environment variables
# - Where to send logs
resource "aws_ecs_task_definition" "api" {
  family                   = "${var.project_name}-api"
  network_mode             = "awsvpc"
  # awsvpc = each task gets its own network interface
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  # Container definition — describes our API container
  container_definitions = jsonencode([{
    name  = "${var.project_name}-api"
    image = "${aws_ecr_repository.api.repository_url}:latest"
    # Uses the ECR repo we created above

    portMappings = [{
      containerPort = var.container_port
      protocol      = "tcp"
    }]

    # Environment variables passed into the container
    # These replace what was in our .env file
    environment = [
      {
        name  = "PORT"
        value = tostring(var.container_port)
      },
      {
        name  = "AWS_REGION"
        value = var.aws_region
      },
      {
        name  = "REVIEWS_TABLE"
        value = "cryptobliss-reviews"
      },
      {
        name  = "FEEDBACK_TABLE"
        value = "cryptobliss-feedback"
      },
      {
        name  = "NODE_ENV"
        value = "production"
      }
    ]

    # Send container logs to CloudWatch
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/${var.project_name}-api"
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }

    essential = true
    # essential = true means if this container stops
    # the entire task stops and ECS restarts it
  }])

  tags = {
    Name        = "${var.project_name}-task"
    Environment = var.environment
  }
}

# APPLICATION LOAD BALANCER
# Sits in front of our ECS containers
# Receives all internet traffic and forwards to containers
# Also provides a stable DNS name for our API
resource "aws_lb" "api" {
  name               = "${var.project_name}-alb"
  internal           = false
  # internal = false means it faces the internet
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
  # Lives in public subnets to receive internet traffic

  tags = {
    Name        = "${var.project_name}-alb"
    Environment = var.environment
  }
}

# TARGET GROUP
# Defines which containers receive traffic from the ALB
# and how to check if they are healthy
resource "aws_lb_target_group" "api" {
  name        = "${var.project_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  # target_type = ip is required for Fargate

  # Health check — ALB regularly pings /health
  # to verify containers are working
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "${var.project_name}-tg"
    Environment = var.environment
  }
}

# ALB LISTENER
# Tells the ALB to listen on port 80
# and forward traffic to our target group
resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.api.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

# ECS SERVICE
# Keeps our container running 24/7
# If the container crashes ECS automatically
# starts a new one
resource "aws_ecs_service" "api" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  # Network configuration for the containers
  network_configuration {
    subnets          = aws_subnet.private[*].id
    # Containers live in PRIVATE subnets
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
    # No public IP — traffic must come through ALB
  }

  # Connect service to Load Balancer
  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "${var.project_name}-api"
    container_port   = var.container_port
  }

  depends_on = [
    aws_lb_listener.api,
    aws_iam_role_policy_attachment.ecs_execution
  ]

  tags = {
    Name        = "${var.project_name}-service"
    Environment = var.environment
  }
}