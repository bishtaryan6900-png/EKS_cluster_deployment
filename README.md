# AWS EKS Cluster Deployment via Terraform & Jenkins

This repository contains the Terraform infrastructure-as-code (IaC) configuration to deploy a high-availability Amazon EKS (Elastic Kubernetes Service) cluster along with a custom AWS VPC, automated end-to-end via a Jenkins CI/CD pipeline.

---

## Architecture Overview

* **VPC Infrastructure:**
  * Multi-AZ deployment (Public and Private Subnets).
  * Single NAT Gateway for outbound internet access from private subnets.
  * DNS Hostnames and Resolution enabled.
  * Auto-discovery tags for Kubernetes Load Balancers (`kubernetes.io/role/elb` and `kubernetes.io/role/internal-elb`).
* **EKS Cluster:**
  * Managed Node Groups placed securely inside private subnets.
  * Control Plane ENIs associated with VPC subnets.
* **CI/CD Automation:**
  * Jenkins Pipeline performing automated code checkout, initialization, formatting, validation, planning, and execution.

---

## Directory Structure

```text
.
├── Jenkinsfile              # Declarative Jenkins pipeline definition
├── EKS/                     # Terraform configuration directory
│   ├── main.tf              # Primary Terraform module declarations (VPC & EKS)
│   ├── variables.tf         # Input variable definitions
│   ├── outputs.tf           # Output values (Cluster endpoint, VPC ID, etc.)
│   ├── terraform.tfvars     # Environment variable values
│   └── provider.tf          # AWS provider configuration
└── README.md                # Project documentation
