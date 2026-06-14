

# VPC 
# Virtual Private Cloud — our private network on AWS
# Everything we create lives inside this VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  # DNS settings allow resources inside the VPC
  # to resolve AWS service hostnames automatically

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
    Project     = var.project_name
  }
}

# INTERNET GATEWAY 
# The door between our VPC and the internet
# Without this nothing in our VPC can reach the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  # aws_vpc.main.id references the VPC we just created
  # Terraform automatically knows to create the VPC
  # before the Internet Gateway

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

# PUBLIC SUBNETS 
# Public subnets are connected to the Internet Gateway
# Our Load Balancer lives here — it needs to be
# reachable from the internet
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  # count creates multiple resources at once
  # length(["10.0.1.0/24", "10.0.2.0/24"]) = 2
  # So this creates 2 public subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  # Spread across different AZs for high availability
  # Subnet 1 → us-east-1a, Subnet 2 → us-east-1b

  map_public_ip_on_launch = true
  # Instances in public subnets get public IPs automatically

  tags = {
    Name        = "${var.project_name}-public-${count.index + 1}"
    Environment = var.environment
  }
}

# PRIVATE SUBNETS 
# Private subnets have NO direct internet access
# Our ECS containers live here — safer, not exposed
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "${var.project_name}-private-${count.index + 1}"
    Environment = var.environment
  }
}

# ELASTIC IP FOR NAT GATEWAY 
# A fixed public IP address for the NAT Gateway
# NAT Gateway needs a static IP to send traffic out
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }

  depends_on = [aws_internet_gateway.main]
  # depends_on tells Terraform to create the IGW first
  # before creating this Elastic IP
}

# NAT GATEWAY
# Allows private subnet resources to reach the internet
# for outbound requests (e.g. calling AWS Comprehend)
# but blocks ALL inbound internet traffic
#
# Think of it like a one-way door —
# private resources can go OUT but nothing comes IN
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  # NAT Gateway lives in public subnet
  # but serves the private subnets

  tags = {
    Name        = "${var.project_name}-nat"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.main]
}

# PUBLIC ROUTE TABLE
# Rules for how traffic flows in public subnets
# This says: send all internet traffic to the IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    # 0.0.0.0/0 means ALL internet traffic
    gateway_id = aws_internet_gateway.main.id
    # Send it through the Internet Gateway
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
  }
}

# PRIVATE ROUTE TABLE
# Rules for how traffic flows in private subnets
# This says: send internet traffic through NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
    # Private resources go THROUGH NAT not directly out
  }

  tags = {
    Name        = "${var.project_name}-private-rt"
    Environment = var.environment
  }
}

# ROUTE TABLE ASSOCIATIONS 
# Connect route tables to their subnets
# Without this, subnets don't know which rules to follow

# Public subnets use public route table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private subnets use private route table
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}