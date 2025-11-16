# ⭐ **DevSecOps Infrastructure on AWS (Terraform + Ansible + EKS)**

<p align="center">
  <img src="assets/banner.png" width="100%" />
</p>

<h1 align="center">⚡ Enterprise DevSecOps Infrastructure</h1>

<p align="center">
  <b>Automated AWS Infrastructure with Terraform, Ansible, Jenkins, Nexus, SonarQube, and Amazon EKS</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/AWS-Cloud%20Infra-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white"/>
  <img src="https://img.shields.io/badge/Terraform-IaC-7B42BC?style=for-the-badge&logo=terraform&logoColor=white"/>
  <img src="https://img.shields.io/badge/Ansible-Automation-EE0000?style=for-the-badge&logo=ansible&logoColor=white"/>
  <img src="https://img.shields.io/badge/Kubernetes-EKS-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white"/>
</p>

---

# 📘 **Overview**

This repository builds a **production-style DevSecOps infrastructure** entirely using:

- **Terraform**
- **Ansible**
- **EC2** instances for Jenkins / Nexus / SonarQube
- **Amazon EKS** for Kubernetes orchestration

It fully satisfies the assignment’s **Expected Deliverables**.

---

# 🏛️ **Architecture Diagram**

```
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
```

---

# 📂 **Repository Structure**

```
.
├── ansible/
│   ├── roles/
│   ├── inventory/
│   └── site.yml
├── Execution Example Screenshot/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── aws.sh
└── README.md
```

---

# 🚀 **Terraform Deployment**

### Initialize
```bash
terraform init
```

### Apply
```bash
terraform apply
```

### Destroy
```bash
terraform destroy
```

Created resources include:

- VPC, subnets, route tables
- Internet Gateway
- Security groups
- EC2 instances (Jenkins, Nexus, SonarQube)
- Key pairs
- EKS cluster + Managed Node Group
- Ansible inventory

---

# 🤖 **Ansible Configuration**

### Run
```bash
ansible-playbook -i ansible/inventory/hosts.ini ansible/site.yml
```

### Installs

| Tool | Port |
|------|------|
| Jenkins | 8080 |
| Nexus | 8081 |
| SonarQube | 9000 |
| Docker | — |

---

# ☸️ **Amazon EKS Cluster**

### Configure kubeconfig
```bash
terraform output secure_shop_eks_kubeconfig > kubeconfig_secure_shop
export KUBECONFIG=$PWD/kubeconfig_secure_shop
```

### Validate
```bash
kubectl get nodes
```

Nodes must be **Ready**.

---

# 🖼 **Screenshots (Required Deliverables)**

All screenshots stored in:

```
Execution Example Screenshot/
```

Include:

- Terraform apply success
- VPC view
- Subnets
- EC2 list
- Jenkins UI
- Nexus UI
- SonarQube UI
- kubectl get nodes

---

# 🎯 **Tools Used**

| Tool | Purpose |
|------|---------|
| AWS | Cloud provider |
| Terraform | Infrastructure as Code |
| Ansible | Configuration automation |
| Kubernetes (EKS) | Orchestration |
| Jenkins | CI/CD |
| Nexus | Artifact repository |
| SonarQube | Code quality |

---

# 🌟 **Portfolio Summary**

This project showcases:

- Cloud infrastructure design
- Terraform IaC expertise
- Automated provisioning with Ansible
- Kubernetes cluster deployment
- Realistic DevSecOps pipeline foundation

---

# 🧹 Cleanup

```bash
terraform destroy
```

---

# 📫 Contact

**Cloud Xu**  
GitHub: https://github.com/dx1004
