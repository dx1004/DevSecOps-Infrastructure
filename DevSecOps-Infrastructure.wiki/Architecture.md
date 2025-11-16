# AWS + DevSecOps Architecture

This infrastructure is designed to replicate a realistic production-grade DevSecOps environment.

## High-Level Diagram (ASCII)

```text
AWS VPC (10.0.0.0/16)
|
+-- Public Subnets
|   +-- Jenkins EC2 (8080)
|   +-- Nexus EC2 (8081)
|   +-- SonarQube EC2 (9000)
|
+-- Private Subnets
    +-- Amazon EKS Cluster (secure-shop-eks)
        +-- Managed Node Group (t3.medium)
```

