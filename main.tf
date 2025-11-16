provider "aws" {
  region = var.region
}

locals {
  public_subnet_map = {
    for subnet in var.public_subnets : subnet.name => subnet
  }

  private_subnet_map = {
    for subnet in var.private_subnets : subnet.name => subnet
  }

  kube_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public" {
  for_each = local.public_subnet_map

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = each.value.name
      "kubernetes.io/role/elb" = "1"
    },
    local.kube_tags,
  )
}

resource "aws_subnet" "private" {
  for_each = local.private_subnet_map

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    {
      Name = each.value.name
      "kubernetes.io/role/internal-elb" = "1"
    },
    local.kube_tags,
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "jenkins" {
  name        = "jenkins-sg"
  description = "Jenkins Server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

resource "aws_security_group" "nexus" {
  name        = "nexus-sg"
  description = "Nexus Server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Nexus UI"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nexus-sg"
  }
}

resource "aws_security_group" "sonarqube" {
  name        = "sonarqube-sg"
  description = "SonarQube Server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SonarQube UI"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sonarqube-sg"
  }
}

resource "tls_private_key" "jenkins" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "jenkins" {
  key_name   = var.key_name
  public_key = tls_private_key.jenkins.public_key_openssh
}

resource "local_sensitive_file" "jenkins_key" {
  filename        = "${path.module}/${var.key_name}.pem"
  content         = tls_private_key.jenkins.private_key_pem
  file_permission = "0400"
}

resource "tls_private_key" "eks" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "eks" {
  key_name   = var.eks_key_name
  public_key = tls_private_key.eks.public_key_openssh
}

resource "local_sensitive_file" "eks_key" {
  filename        = "${path.module}/${var.eks_key_name}.pem"
  content         = tls_private_key.eks.private_key_pem
  file_permission = "0400"
}

locals {
  server_configs = {
    jenkins = {
      name = "Jenkins-Server"
      sg   = aws_security_group.jenkins.id
    }
    nexus = {
      name = "Nexus-Server"
      sg   = aws_security_group.nexus.id
    }
    sonarqube = {
      name = "SonarQube-Server"
      sg   = aws_security_group.sonarqube.id
    }
  }
}

resource "aws_instance" "servers" {
  for_each = local.server_configs

  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.jenkins.key_name
  subnet_id                   = aws_subnet.public["PUB_SUBNET1"].id
  vpc_security_group_ids      = [each.value.sg]
  associate_public_ip_address = true

  tags = {
    Name = each.value.name
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/ansible/inventory/hosts.ini"
  content = templatefile("${path.module}/ansible/inventory/hosts.ini.tmpl", {
    jenkins_ip       = aws_instance.servers["jenkins"].public_ip
    nexus_ip         = aws_instance.servers["nexus"].public_ip
    sonarqube_ip     = aws_instance.servers["sonarqube"].public_ip
    private_key_path = local_sensitive_file.jenkins_key.filename
  })

  depends_on = [aws_instance.servers]
}

module "secure_shop_eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.8.0"

  name               = var.eks_cluster_name
  kubernetes_version = var.eks_cluster_version

  endpoint_public_access                   = true
  enable_irsa                              = true
  enable_cluster_creator_admin_permissions  = true

  vpc_id                   = aws_vpc.main.id
  subnet_ids               = [for subnet in aws_subnet.public : subnet.id]
  control_plane_subnet_ids = distinct(concat(
    [for subnet in aws_subnet.public : subnet.id],
    [for subnet in aws_subnet.private : subnet.id]
  ))

  # Cluster-only; node groups and addons are defined as standalone resources below to control ordering.
  eks_managed_node_groups = {}

  tags = {
    Project = var.vpc_name
  }
}


data "aws_eks_addon_version" "coredns_latest" {
  addon_name         = "coredns"
  kubernetes_version = var.eks_cluster_version
  most_recent        = true
}

# Core control-plane/network addons follow the eksctl order: apply right after the
# control plane is ready, before managed node groups.
resource "aws_eks_addon" "eks_pod_identity_agent" {
  cluster_name                = module.secure_shop_eks.cluster_name
  addon_name                  = "eks-pod-identity-agent"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [module.secure_shop_eks]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = module.secure_shop_eks.cluster_name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_addon.eks_pod_identity_agent]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = module.secure_shop_eks.cluster_name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_addon.vpc_cni]
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = module.secure_shop_eks.cluster_name
  addon_name                  = "coredns"
  addon_version               = data.aws_eks_addon_version.coredns_latest.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_addon.kube_proxy]
}

# IAM role for managed node group
resource "aws_iam_role" "eks_nodegroup" {
  name = "${var.eks_cluster_name}-nodegroup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_worker" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup.name
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup.name
}

resource "aws_iam_role_policy_attachment" "eks_nodegroup_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup.name
}

# Allow node instances to call EBS APIs when controller pods fall back to the node role.
resource "aws_iam_role_policy_attachment" "eks_nodegroup_ebs" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_nodegroup.name
}

# Managed node group created after control-plane/network addons.
resource "aws_eks_node_group" "worker_nodes" {
  cluster_name    = module.secure_shop_eks.cluster_name
  node_group_name = "worker-nodes"
  node_role_arn   = aws_iam_role.eks_nodegroup.arn

  subnet_ids = [for subnet in aws_subnet.public : subnet.id]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 2
  }

  instance_types = [var.eks_node_instance_type]
  ami_type       = "AL2_x86_64"
  disk_size      = 20
  capacity_type  = "ON_DEMAND"

  labels = {
    role = "jenkins"
  }

  tags = {
    Name = "worker-nodes"
  }

  depends_on = [
    module.secure_shop_eks,
    aws_iam_role_policy_attachment.eks_nodegroup_worker,
    aws_iam_role_policy_attachment.eks_nodegroup_cni,
    aws_iam_role_policy_attachment.eks_nodegroup_ecr
  ]
}

# Node-dependent addons applied after nodegroups are up, matching the eksctl deployment order.
resource "aws_eks_addon" "aws_ebs_csi_driver" {
  cluster_name         = module.secure_shop_eks.cluster_name
  addon_name           = "aws-ebs-csi-driver"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  configuration_values = null

  depends_on = [
    module.secure_shop_eks,
    aws_eks_node_group.worker_nodes
  ]
}

resource "aws_eks_addon" "metrics_server" {
  cluster_name      = module.secure_shop_eks.cluster_name
  addon_name        = "metrics-server"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    module.secure_shop_eks,
    aws_eks_node_group.worker_nodes,
    aws_eks_addon.aws_ebs_csi_driver
  ]
}
