## 🏗️ Terraform Infrastructure Repository

Serverless CI/CD Infrastructure on AWS (Terraform)

This repository contains the Terraform code used to provision a fully serverless CI/CD infrastructure on AWS. It creates all the required resources, including VPC networking, ECS (Fargate), ECR, Application Load Balancer, IAM roles, and CloudWatch logging.

The infrastructure is designed to support automated deployments via GitHub Actions and to run containerized frontend and backend services without Kubernetes.

This infrastructure is part of a complete serverless CI/CD example described in this Medium post:

[Building a Serverless CI/CD Pipeline on AWS with Github Actions and Terraform](https://medium.com/@davidiriondopalacios/building-a-serverless-ci-cd-pipeline-on-aws-with-github-actions-and-terraform-dae596f1d2e0)

## Run infrastructure

Mandatory variable
```
terraform apply -var="github_owner=your_github_organization"
```

Optional variables
1. task_def_back
2. task_def_front

Both specify a task definition ARN to run infraestructure with. In case no value is defined then teraform will create ECS with dummy images.

This is usefully if you already have created the infrastructure then you want to re-run infraestructure code again and you dont want to lose last version of your task definition

```
terraform plan -var="github_owner=your_github_organization" \
-var="task_def_back=ARN" \
-var="task_def_front=ARN"
```