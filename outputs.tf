output "vpc_id" {
  description = "ID of the Jenkins VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs for the public subnets."
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "IDs for the private subnets."
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "security_groups" {
  description = "Security group IDs keyed by service."
  value = {
    jenkins   = aws_security_group.jenkins.id
    nexus     = aws_security_group.nexus.id
    sonarqube = aws_security_group.sonarqube.id
  }
}

output "instance_public_ips" {
  description = "Public IPs for Jenkins, Nexus, and SonarQube."
  value = {
    for name, instance in aws_instance.servers : name => instance.public_ip
  }
}

output "jenkins_public_ip" {
  description = "Jenkins server public IP."
  value       = aws_instance.servers["jenkins"].public_ip
}

output "nexus_public_ip" {
  description = "Nexus server public IP."
  value       = aws_instance.servers["nexus"].public_ip
}

output "sonarqube_public_ip" {
  description = "SonarQube server public IP."
  value       = aws_instance.servers["sonarqube"].public_ip
}

output "key_pair_name" {
  description = "Name of the generated EC2 key pair."
  value       = aws_key_pair.jenkins.key_name
}

output "private_key_file" {
  description = "Path to the PEM file written locally."
  value       = local_sensitive_file.jenkins_key.filename
}

output "ansible_inventory_file" {
  description = "Path to the generated Ansible inventory."
  value       = local_file.ansible_inventory.filename
}

output "secure_shop_eks_cluster_name" {
  description = "Name of the secure-shop-eks cluster."
  value       = module.secure_shop_eks.cluster_name
}

output "secure_shop_eks_cluster_endpoint" {
  description = "API server endpoint for the secure-shop-eks cluster."
  value       = module.secure_shop_eks.cluster_endpoint
}

output "secure_shop_eks_cluster_certificate_authority_data" {
  description = "Base64 encoded CA data for the cluster."
  value       = module.secure_shop_eks.cluster_certificate_authority_data
}

output "secure_shop_eks_kubeconfig" {
  description = "Rendered kubeconfig for secure-shop-eks."
  value = templatefile("${path.module}/templates/kubeconfig.tpl", {
    cluster_name     = module.secure_shop_eks.cluster_name
    cluster_endpoint = module.secure_shop_eks.cluster_endpoint
    cluster_ca       = module.secure_shop_eks.cluster_certificate_authority_data
    region           = var.region
  })
  sensitive = true
}

output "eks_worker_key_file" {
  description = "Path to the PEM file for the EKS worker SSH key."
  value       = local_sensitive_file.eks_key.filename
}
