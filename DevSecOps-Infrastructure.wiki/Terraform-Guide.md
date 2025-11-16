# Terraform Deployment Guide

This guide explains how to deploy the infrastructure using Terraform.

## Prerequisites

- AWS account and credentials configured (AWS CLI)
- Terraform installed
- Ansible, kubectl installed (for later steps)

## 1. Initialize Terraform

From the repository root:

```bash
terraform init
```

## 2. Apply Infrastructure

```bash
terraform apply
```

Terraform will provision:

- VPC, subnets, route tables
- Internet Gateway
- Security groups
- EC2 instances for Jenkins, Nexus, SonarQube
- Key pairs
- EKS cluster and managed node group
- Ansible inventory

## 3. View Outputs

```bash
terraform output
```

This can include public IPs and EKS kubeconfig data.

## 4. Destroy Infrastructure

When you are done and want to avoid charges:

```bash
terraform destroy
```
