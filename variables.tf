variable "region" {
  description = "AWS region where all resources are created."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the Jenkins VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name tag applied to the VPC."
  type        = string
  default     = "Jenkins-EKS"
}

variable "cluster_name" {
  description = "Cluster tag value used on the subnets for EKS readiness."
  type        = string
  default     = "jenkins-secureapp"
}

variable "public_subnets" {
  description = "Configuration for the public subnets."
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  default = [
    {
      name = "PUB_SUBNET1"
      cidr = "10.0.1.0/24"
      az   = "us-east-1a"
    },
    {
      name = "PUB_SUBNET2"
      cidr = "10.0.2.0/24"
      az   = "us-east-1b"
    }
  ]
}

variable "private_subnets" {
  description = "Configuration for the private subnets."
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  default = [
    {
      name = "PRI_SUBNET1"
      cidr = "10.0.3.0/24"
      az   = "us-east-1a"
    },
    {
      name = "PRI_SUBNET2"
      cidr = "10.0.4.0/24"
      az   = "us-east-1b"
    }
  ]
}

variable "ami_id" {
  description = "AMI used for all three EC2 instances."
  type        = string
  default     = "ami-0ecb62995f68bb549"
}

variable "instance_type" {
  description = "Instance type for Jenkins, Nexus, and SonarQube servers."
  type        = string
  default     = "t3.medium"
}

variable "key_name" {
  description = "Name of the EC2 key pair."
  type        = string
  default     = "jenkins-key"
}

variable "eks_key_name" {
  description = "Name of the SSH key pair assigned to EKS worker nodes."
  type        = string
  default     = "jenkins-cluster-key"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "secure-shop-eks"
}

variable "eks_cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.32"
}

variable "eks_node_instance_type" {
  description = "Instance type for the managed node group."
  type        = string
  default     = "t3.medium"
}
