# AWS EKS & Jenkins Infrastructure Deployment via Terraform

This repository contains complete Terraform Infrastructure as Code (IaC) to provision both a Jenkins CI/CD server and a high-availability Amazon EKS (Elastic Kubernetes Service) cluster with a custom AWS VPC. It includes an automated Jenkins declarative pipeline for end-to-end continuous deployment of the EKS environment.

---

## Architecture Overview

* **Jenkins Server Infrastructure (`/jenkins-server`):** Provisioning of the dedicated Jenkins host infrastructure (EC2, security groups, IAM roles).
* **VPC Infrastructure (`/EKS`):**
  * Multi-AZ deployment with public and private subnets.
  * Single NAT Gateway for private subnet outbound access.
  * Auto-discovery tags for Kubernetes Load Balancers (`kubernetes.io/role/elb` and `kubernetes.io/role/internal-elb`).
* **EKS Cluster (`/EKS`):**
  * Managed Node Groups deployed inside private subnets for enhanced security.
  * AWS-managed control plane network interfaces (ENIs) attached to VPC subnets.
* **CI/CD Automation (`Jenkinsfile`):**
  * Automated pipeline managing the EKS lifecycle: `init` → `fmt` → `validate` → `plan` → `apply`.

---

## Directory Structure

```text
.
├── Jenkinsfile              # Declarative Jenkins pipeline for EKS infrastructure
├── README.md                # Project documentation
├── jenkins-server/          # Terraform configuration to deploy the Jenkins server
│   ├── main.tf              # EC2, Security Group, and IAM setup for Jenkins
│   ├── variables.tf         # Input variables for the Jenkins host
│   └── outputs.tf           # Outputs (e.g., Jenkins public IP)
└── EKS/                     # Terraform configuration for EKS & VPC
    ├── main.tf              # Primary module declarations (VPC & EKS)
    ├── variables.tf         # Input variable definitions
    ├── outputs.tf           # Output values (Cluster endpoint, VPC ID, etc.)
    ├── terraform.tfvars     # Environment variable values
    └── provider.tf          # AWS provider configuration
