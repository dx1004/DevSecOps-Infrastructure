# Jenkins Toolchain Terraform

Terraform configuration that reproduces the AWS infrastructure previously created with `aws.sh`.

## What gets created

- VPC (`10.0.0.0/16`) named `Jenkins-EKS`
- Two public subnets and two private subnets tagged for EKS
- Internet gateway and public route table with a default route
- Security groups dedicated to Jenkins, Nexus, and SonarQube
- RSA key pair named `jenkins-key` (PEM file saved locally with `0400` permissions)
- Three EC2 instances (Jenkins, Nexus, SonarQube) in the first public subnet

## Usage

```bash
terraform init           # download providers and set up the working directory
terraform apply          # review and confirm to create the infrastructure
terraform destroy        # tear everything down when you are done
```

## Configure servers with Ansible

1. Run `terraform apply` first. It will also drop an inventory at `ansible/inventory/hosts.ini` that already contains the freshly created public IPs and the SSH key path.
2. Install the required Ansible collection once: `ansible-galaxy collection install -r ansible/requirements.yml`.
3. Execute the playbook: `ansible-playbook -i ansible/inventory/hosts.ini ansible/site.yml`.

The playbook runs a common role (Git, Curl, Unzip, Docker), installs Jenkins (Java + service on 8080), and launches Nexus (8081) and SonarQube (9000) in Docker containers.

## secure-shop-eks cluster

Terraform also provisions an Amazon EKS cluster named `secure-shop-eks` using the upstream `terraform-aws-modules/eks/aws` module:

- Kubernetes version `1.32`
- Control plane spans all four subnets created earlier
- One managed node group (`worker-nodes`) sized 1–2 `t3.medium` instances with SSH enabled through `jenkins-cluster-key`

After `terraform apply`, grab kubeconfig data using:

```bash
terraform output secure_shop_eks_kubeconfig > kubeconfig_secure_shop
export KUBECONFIG=$PWD/kubeconfig_secure_shop
kubectl get nodes
```

The worker SSH private key is saved locally as `jenkins-cluster-key.pem` next to the Terraform files.

## Verify the toolchain

- Jenkins: `http://<jenkins_public_ip>:8080`
- Nexus: `http://<nexus_public_ip>:8081`
- SonarQube: `http://<sonarqube_public_ip>:9000`

Use `terraform output -raw jenkins_public_ip` (or the other outputs) to grab the addresses if you need to check them later.

### Notes

- Terraform generates a new 4096-bit RSA key pair during `apply`. The PEM file is written next to the Terraform files and is already ignored by Git.
- Default values match the ones inside `aws.sh`. Override any variable via `-var` or a `.tfvars` file if needed.
- If Terraform is not installed locally, grab it from https://developer.hashicorp.com/terraform/downloads before running the commands above.
