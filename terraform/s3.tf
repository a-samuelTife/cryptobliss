
# Creates S3 bucket for frontend hosting and
# CloudFront distribution to deliver it globally Now includes API proxy — routes /api/* to the ALB so everything goes through HTTPS via CloudFront

# S3 BUCKET 
resource "aws_s3_bucket" "frontend" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "${var.project_name}-frontend"
    Environment = var.environment
  }
}

# BLOCK PUBLIC ACCESS 
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 BUCKET VERSIONING
resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  versioning_configuration {
    status = "Enabled"
  }
}

# CLOUDFRONT ORIGIN ACCESS CONTROL 
# Allows CloudFront to access our private S3 bucket
resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "${var.project_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#  CLOUDFRONT DISTRIBUTION 
# Now has TWO origins:
# 1. S3 bucket — serves the frontend HTML/CSS/JS
# 2. ALB — serves the API at /api/* and /health
resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  default_root_object = "index.html"

  # ORIGIN 1: S3 BUCKET 
  # Serves frontend static files
  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "S3-${var.s3_bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  # ORIGIN 2: API LOAD BALANCER 
  # Serves API requests at /api/* and /health
  # This fixes the Mixed Content error by routing
  # API calls through HTTPS CloudFront instead of
  # HTTP directly to the ALB
  origin {
    domain_name = aws_lb.api.dns_name
    origin_id   = "ALB-API"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      # ALB only has HTTP — CloudFront handles HTTPS
      # CloudFront receives HTTPS from browser
      # then forwards HTTP to the ALB internally
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # CACHE BEHAVIOR 1: /api/* 
  # Routes all API calls to the Load Balancer
  # Must be defined BEFORE default_cache_behavior
  # CloudFront checks ordered behaviors first
  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ALB-API"

    forwarded_values {
      query_string = true
      # Forward query strings to the API
      headers      = ["*"]
      # Forward all headers including Content-Type
      # Required for POST requests with JSON body
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    # Never cache API responses
    # API data changes with every review submitted
  }

  # CACHE BEHAVIOR 2: /health
  # Routes health check to the Load Balancer
  ordered_cache_behavior {
    path_pattern     = "/health"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ALB-API"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  # DEFAULT CACHE BEHAVIOR: 
  # Everything else goes to S3 (frontend files)
  # This is the fallback for all other requests
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.s3_bucket_name}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # Redirect 404 errors to index.html
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  #  SSL CERTIFICATE 
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "${var.project_name}-cdn"
    Environment = var.environment
  }
}

# S3 BUCKET POLICY 
# Allows CloudFront to read files from S3
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowCloudFrontAccess"
      Effect = "Allow"
      Principal = {
        Service = "cloudfront.amazonaws.com"
      }
      Action   = "s3:GetObject"
      Resource = "${aws_s3_bucket.frontend.arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.frontend.arn
        }
      }
    }]
  })
}