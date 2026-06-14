# CryptoBliss — Crypto Sentiment Platform

A full-stack crypto sentiment platform that uses **Amazon Comprehend AI** to automatically analyze user reviews and transaction feedback. Built with Node.js, deployed on AWS using Terraform, with a complete CI/CD pipeline via GitHub Actions.

> ⚠️ Infrastructure has been decommissioned to avoid costs. All code and Terraform files are available to redeploy in under 10 minutes.

---

## Live Demo Screenshots

![CryptoBliss Market Page](https://djdat8fbrgx1w.cloudfront.net)

---

## What It Does

- Browse **20 cryptocurrencies** with simulated prices and 24hr changes
- Submit reviews for any coin — **Amazon Comprehend automatically analyzes the sentiment** (Positive, Negative, Neutral, Mixed)
- Simulate **Buy/Sell transactions** and leave feedback analyzed by AI
- View **community sentiment scores** and breakdown bars per coin
- All reviews and sentiment scores stored in **AWS DynamoDB**

---

## Architecture

```
User → CloudFront (HTTPS) → S3 (Frontend)
                          → ALB → ECS Fargate (API)
                                      ↓
                              Amazon Comprehend (AI)
                              AWS DynamoDB (Database)
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | HTML, CSS, JavaScript |
| Backend | Node.js + Express REST API |
| AI Service | Amazon Comprehend |
| Database | AWS DynamoDB |
| Containerization | Docker |
| Container Registry | AWS ECR |
| Container Deployment | AWS ECS Fargate |
| Load Balancer | AWS Application Load Balancer |
| Frontend Hosting | AWS S3 |
| CDN | AWS CloudFront |
| Networking | AWS VPC, Subnets, IGW, NAT Gateway |
| Infrastructure as Code | Terraform |
| CI/CD | GitHub Actions |
| Security | AWS IAM Roles (least privilege) |

---

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/coins` | Get all 20 coins with sentiment |
| GET | `/api/coins/:id` | Get one coin by ID |
| GET | `/api/reviews/:coinId` | Get all reviews for a coin |
| POST | `/api/reviews` | Submit review — triggers Comprehend AI |
| GET | `/api/feedback/:coinId` | Get transaction feedback |
| POST | `/api/feedback` | Submit feedback — triggers Comprehend AI |
| GET | `/health` | Health check endpoint |

---

## Project Structure

```
cryptobliss/
├── frontend/
│   ├── index.html       # Market page — all 20 coins
│   ├── coin.html        # Coin detail — reviews + feedback
│   └── style.css        # Dark theme styling
│
├── backend/
│   ├── server.js        # Express app entry point
│   ├── coins.js         # 20 cryptocurrency data
│   ├── routes/
│   │   ├── coins.js     # Coin endpoints
│   │   ├── reviews.js   # Review endpoints + Comprehend
│   │   └── feedback.js  # Feedback endpoints + Comprehend
│   ├── services/
│   │   ├── comprehend.js # Amazon Comprehend integration
│   │   └── dynamo.js     # DynamoDB integration
│   └── Dockerfile       # Container build recipe
│
├── terraform/
│   ├── main.tf          # Provider + data sources
│   ├── variables.tf     # Input variables
│   ├── terraform.tfvars # Variable values
│   ├── outputs.tf       # Output values
│   ├── networking.tf    # VPC, subnets, gateways
│   ├── security_groups.tf # Firewall rules
│   ├── ecr.tf           # Container registry
│   ├── ecs.tf           # ECS cluster + service
│   ├── s3.tf            # S3 + CloudFront
│   └── github_actions.tf # CI/CD IAM user
│
└── .github/
    └── workflows/
        └── deploy.yml   # GitHub Actions pipeline
```

---

## Redeploy in Minutes

### Prerequisites
- AWS CLI configured
- Terraform installed
- Docker installed
- Node.js installed

### Deploy Infrastructure
```bash
cd terraform
terraform init
terraform apply
```

### Push Docker Image
```bash
aws ecr get-login-password --region us-east-1 > token.txt
Get-Content token.txt | docker login --username AWS --password-stdin <ECR_URL>
cd backend
docker build -t cryptobliss-api .
docker tag cryptobliss-api:latest <ECR_URL>:latest
docker push <ECR_URL>:latest
```

### Upload Frontend
```bash
aws s3 sync frontend/ s3://<S3_BUCKET> --delete
aws cloudfront create-invalidation --distribution-id <CF_ID> --paths "/*"
```

### Tear Down
```bash
aws s3 rm s3://<S3_BUCKET> --recursive
cd terraform
terraform destroy
```

---

## CI/CD Pipeline

Every push to `main` automatically:
1. Builds Docker image and pushes to ECR
2. Deploys new container to ECS Fargate
3. Uploads frontend to S3
4. Clears CloudFront cache

Total pipeline time: ~3 minutes

---

## AWS Resources Created by Terraform

38 resources including VPC, 4 subnets, Internet Gateway, NAT Gateway, 2 route tables, 2 security groups, ECR repository, ECS cluster, ECS task definition, ECS service, Application Load Balancer, target group, ALB listener, 2 IAM roles, S3 bucket, CloudFront distribution, and GitHub Actions IAM user.

---

## Author

**Abdul Samuel** — AWS Certified Solutions Architect | Cloud Engineer
GitHub: [github.com/a-samuelTife](https://github.com/a-samuelTife)