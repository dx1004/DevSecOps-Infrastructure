<p align="center">
  <img src="https://raw.githubusercontent.com/dx1004/DevSecOps-Infrastructure/main/assets/banner.png" width="100%" />
</p>

<h1 align="center">⚡ DevSecOps Infrastructure on AWS</h1>

<p align="center">
  <img src="https://img.shields.io/badge/AWS-Cloud%20Infra-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white"/>
  <img src="https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white"/>
  <img src="https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white"/>
  <img src="https://img.shields.io/badge/Kubernetes-EKS-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white"/>
</p>

---

# DevSecOps Infrastructure (Terraform + EKS)

Infrastructure-as-code to stand up a Jenkins-centric toolchain VPC, EC2 hosts (Jenkins/Nexus/SonarQube), and an EKS cluster with ordered addon deployment matching the observed eksctl flow from the GitHub wiki.

## What this deploys

- VPC with public/private subnets, IGW, route tables, and Kubernetes-ready subnet tags.
- Security groups for Jenkins, Nexus, and SonarQube.
- EC2 instances for Jenkins, Nexus, and SonarQube plus an SSH keypair written locally (`jenkins-key.pem`).
- EKS cluster (`secure-shop-eks`) with a managed node group and addons sequenced as: control-plane/network (`eks-pod-identity-agent`, `vpc-cni`, `kube-proxy`, `coredns`) then node-dependent (`aws-ebs-csi-driver`, `metrics-server`).
- Generated artifacts: Ansible inventory (`ansible/inventory/hosts.ini`) and PEM keys for EC2 and EKS worker SSH access.

## Prerequisites

- Terraform >= 1.5
- AWS CLI configured with credentials and default region (or set `AWS_PROFILE`/`AWS_REGION`)
- kubectl (to interact with the EKS cluster)
- Optional: eksctl (for cross-checking with `jenkins-eks-cluster.yaml`)

## Step-by-step execution guide

### 1) Prepare

- Clone the repo and `cd` into it (Terraform files are at repo root; Ansible under `ansible/`).
- Export AWS credentials/config or set `AWS_PROFILE`.
- (Optional) Update `variables.tf` defaults or provide overrides via `terraform.tfvars` / `-var`.

### 2) Provision infrastructure with Terraform

```bash
terraform init
terraform plan -out=tfplan   # recommended to lock the apply plan
terraform apply tfplan
```

Key outputs: VPC, subnets/route tables/IGW, security groups, EC2 hosts (Jenkins/Nexus/SonarQube) with `jenkins-key.pem`, EKS cluster `secure-shop-eks` + node group, addons ordered as per eksctl run, generated Ansible inventory at `ansible/inventory/hosts.ini`.

### 3) Configure servers with Ansible

Install Ansible deps (if needed):

```bash
cd ansible
ansible-galaxy install -r requirements.yml
```

Run the main playbook (uses generated inventory and `jenkins-key.pem`):

```bash
ansible-playbook -i inventory/hosts.ini site.yml
```

Roles executed: `common`, `jenkins`, `nexus`, `sonarqube`.

### 4) Validate EKS

```bash
aws eks update-kubeconfig --name secure-shop-eks --region us-east-1
kubectl get nodes
kubectl get pods -A
```

Ensure node(s) are Ready and core addons are Running before deploying workloads.

## Key artifacts and outputs

- PEM keys: `jenkins-key.pem` and `jenkins-cluster-key.pem` written locally with `0400` permissions.
- Ansible inventory: `ansible/inventory/hosts.ini` generated with public IPs for Jenkins/Nexus/SonarQube.
- EKS kubeconfig (template output): see `secure_shop_eks_kubeconfig` output for a rendered config using `templates/kubeconfig.tpl`.
- All outputs: `terraform output` after apply.

## Addon ordering (matches eksctl log)

- Control plane/network installed with the EKS module: `eks-pod-identity-agent`, `vpc-cni`, `kube-proxy`, `coredns`.
- Node-dependent addons applied after the node group is Ready via `aws_eks_addon`: `aws-ebs-csi-driver`, `metrics-server`.

## Cleanup

```bash
terraform destroy
```

This will remove the VPC, EC2 hosts, EKS cluster, and generated local keys/inventory.

For more architectural notes and diagrams, see the GitHub wiki: https://github.com/dx1004/DevSecOps-Infrastructure/wiki
