⭐ DevSecOps Infrastructure on AWS (Terraform + Ansible + EKS)
<p align="center"> <img src="https://img.shields.io/badge/AWS-Cloud%20Infra-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white"/> <img src="https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white"/> <img src="https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white"/> <img src="https://img.shields.io/badge/Kubernetes-EKS-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white"/> </p> <p align="center">A production-style, fully automated DevSecOps environment built on AWS using Terraform, Ansible, and Amazon EKS.</p>
📘 Project Overview

This project provisions a complete DevSecOps infrastructure stack that includes:

Infrastructure as Code (Terraform)

Configuration automation (Ansible)

Amazon EKS cluster for Kubernetes workloads

Jenkins, Nexus, and SonarQube as the DevSecOps toolchain

This setup mirrors a real-world enterprise environment and follows the exact expected deliverables required in the assignment.

🏛 Architecture Diagram

(If you want, I can generate a polished black-gold PNG/SVG version.)

AWS VPC (10.0.0.0/16)
│
├── Public Subnets
│    ├── Jenkins EC2 (8080)
│    ├── Nexus EC2 (8081)
│    └── SonarQube EC2 (9000)
│
└── Private Subnets
     └── Amazon EKS Cluster (secure-shop-eks)
          └── Worker Node Group (t3.medium)

📂 Repository Structure
.
├── ansible/
│   ├── roles/
│   ├── inventory/ (auto-generated)
│   └── site.yml
├── Execution Example Screenshot/   <-- Required Deliverables
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── aws.sh (optional manual script)
└── README.md

🚀 Infrastructure Provisioning (Terraform)
Required Deliverable
1️⃣ Initialize Terraform
terraform init

2️⃣ Create Infrastructure
terraform apply


Terraform will create:

VPC, subnets, route tables

Internet Gateway

Security groups

EC2 instances (Jenkins, Nexus, SonarQube)

RSA key pairs

EKS cluster + Managed Node Group

Ansible inventory file

3️⃣ Destroy Infrastructure
terraform destroy

🤖 Configuration Automation (Ansible)
Required Deliverable

After Terraform finishes:

Run Ansible Playbook
ansible-playbook -i ansible/inventory/hosts.ini ansible/site.yml


This installs:

🧩 Jenkins (port 8080)

📦 Nexus (port 8081)

🔍 SonarQube (port 9000)

Docker, Git, unzip, system dependencies

☸️ Amazon EKS Cluster
Required Deliverable
Export kubeconfig:
terraform output secure_shop_eks_kubeconfig > kubeconfig_secure_shop
export KUBECONFIG=$PWD/kubeconfig_secure_shop

Verify Nodes
kubectl get nodes


Expected: worker nodes in Ready state.

🖼 Required Screenshots Folder (per PDF)

All screenshots are stored in:

Execution Example Screenshot/


Must include:

Terraform apply success

AWS VPC view

Subnets with auto-assign public IP (for public subnets)

EC2 instances list

Jenkins Web UI

Nexus Web UI

SonarQube Web UI

kubectl get nodes

💡 Tools Used
Tool	Purpose
AWS	Cloud infrastructure
Terraform	Infrastructure as Code
Ansible	Configuration automation
Kubernetes (EKS)	Cluster orchestration
Jenkins	CI/CD
Nexus	Artifact repository
SonarQube	Code quality & security
🎯 Why This Project Is Valuable (Portfolio)

This project demonstrates proficiency in:

Cloud infrastructure design

Terraform modular IaC

Ansible roles & automation

Production-style DevSecOps architecture

Kubernetes cluster provisioning

Secure CI/CD pipeline foundations

Recruiters and hiring managers will recognize:

Real AWS experience

Multi-tool DevOps orchestration

Strong automation skills

Hands-on EKS experience

Ability to deliver full end-to-end infra

🧹 Cleanup
terraform destroy

📫 Contact

Cloud Xu (阿霖)
GitHub: https://github.com/dx1004