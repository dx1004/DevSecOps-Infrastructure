
# Variables
REGION="us-east-1"
VPC_CIDR="10.0.0.0/16"
VPC_NAME="Jenkins-EKS"
ECR_APP_NAME="secureshop"
AWS_ACCOUNT_ID="038184794716"

# Create VPC
VPC_ID=$(aws ec2 create-vpc \
  --cidr-block $VPC_CIDR \
  --region $REGION \
  --query 'Vpc.VpcId' \
  --output text)

# Tag VPC
aws ec2 create-tags --resources $VPC_ID --tags Key=Name,Value=$VPC_NAME

echo "✅ VPC Created: $VPC_ID"


# Public Subnets
# ✅ Public Subnet 1

PUB_SUBNET1=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.1.0/24 \
  --availability-zone us-east-1a \
  --query 'Subnet.SubnetId' \
  --output text)
  
  aws ec2 create-tags \
  --resources $PUB_SUBNET1 \
  --tags 'Key=Name,Value=PUB_SUBNET1' \
         'Key=kubernetes.io/role/elb,Value=1' \
         'Key=kubernetes.io/cluster/jenkins-secureapp,Value=shared'
  aws ec2 modify-subnet-attribute --subnet-id $PUB_SUBNET1 --map-public-ip-on-launch

# ✅ Public Subnet 2
PUB_SUBNET2=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.2.0/24 \
  --availability-zone us-east-1b \
  --query 'Subnet.SubnetId' \
  --output text)
  
  aws ec2 create-tags \
  --resources $PUB_SUBNET2 \
  --tags 'Key=Name,Value=PUB_SUBNET2' \
         'Key=kubernetes.io/role/elb,Value=1' \
         'Key=kubernetes.io/cluster/jenkins-secureapp,Value=shared'
  aws ec2 modify-subnet-attribute --subnet-id $PUB_SUBNET2 --map-public-ip-on-launch
# Private Subnets
# ✅ Private Subnet 1
PRI_SUBNET1=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.3.0/24 \
  --availability-zone us-east-1a \
  --query 'Subnet.SubnetId' \
  --output text)
  
  aws ec2 create-tags \
  --resources $PRI_SUBNET1 \
  --tags 'Key=Name,Value=PRI_SUBNET1' \
         'Key=kubernetes.io/role/internal-elb,Value=1' \
         'Key=kubernetes.io/cluster/jenkins-secureapp,Value=shared'


# ✅ Private Subnet 2
PRI_SUBNET2=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.4.0/24 \
  --availability-zone us-east-1b \
  --query 'Subnet.SubnetId' \
  --output text)
  
  aws ec2 create-tags \
  --resources $PRI_SUBNET2 \
  --tags 'Key=Name,Value=PRI_SUBNET2' \
         'Key=kubernetes.io/role/internal-elb,Value=1' \
         'Key=kubernetes.io/cluster/jenkins-secureapp,Value=shared'

echo "✅ Public Subnets: $PUB_SUBNET1, $PUB_SUBNET2"
echo "✅ Private Subnets: $PRI_SUBNET1, $PRI_SUBNET2"


# Internet Gateway and Route Tables
IGW_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID
aws ec2 create-tags --resources $IGW_ID --tags Key=Name,Value=${VPC_NAME}-igw

PUB_RT_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-route --route-table-id $PUB_RT_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID

aws ec2 associate-route-table --route-table-id $PUB_RT_ID --subnet-id $PUB_SUBNET1
aws ec2 associate-route-table --route-table-id $PUB_RT_ID --subnet-id $PUB_SUBNET2

echo "✅ Internet Gateway: $IGW_ID"
echo "✅ Public Route Table: $PUB_RT_ID"


# Security Group for Jenkins Server
SG_ID_1=$(aws ec2 create-security-group \
  --group-name jenkins-sg \
  --description "Jenkins Server" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text)

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID_1 \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID_1 \
  --protocol tcp \
  --port 8080 \
  --cidr 0.0.0.0/0
  
 aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID_1 \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0
echo "✅ Security Group Created: $SG_ID_1"

# Security Group for Nexus Server
SG_ID_2=$(aws ec2 create-security-group \
  --group-name nexus-sg \
  --description "Nexus Server" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text)

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID_2 \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID_2 \
  --protocol tcp \
  --port 8081 \
  --cidr 0.0.0.0/0
  
 aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID_2 \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0
echo "✅ Security Group Created: $SG_ID_1"

# Security Group for SonarQube Server
SG_ID_3=$(aws ec2 create-security-group \
  --group-name sonarqube-sg \
  --description "SonarQube Server" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text)

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID_3 \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID_3 \
  --protocol tcp \
  --port 9000 \
  --cidr 0.0.0.0/0
  
 aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID_3 \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0
echo "✅ Security Group Created: $SG_ID_1"

AMI_ID="ami-0ecb62995f68bb549"
KEY_NAME="jenkins-key"


# Create and save a new PEM key

aws ec2 create-key-pair \
  --key-name $KEY_NAME \
  --query "KeyMaterial" \
  --output text > ${KEY_NAME}.pem

# Restrict permissions
chmod 400 ${KEY_NAME}.pem

# Verify
ls -l ${KEY_NAME}.pem

# Launch EC2 Instance for Jenkins Server
JENKINS_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --count 1 \
  --instance-type t3.medium \
  --key-name $KEY_NAME \
  --security-group-ids $SG_ID_1 \
  --subnet-id $PUB_SUBNET1 \
  --associate-public-ip-address \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=Jenkins-Server}]" \
  --query "Instances[0].InstanceId" \
  --region us-east-1 \
  --output text)

echo " Jenkins Server Instance ID: $JENKINS_ID"

# Launch EC2 Instance for Nexus Server
NEXUS_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --count 1 \
  --instance-type t3.medium \
  --key-name $KEY_NAME \
  --security-group-ids $SG_ID_2 \
  --subnet-id $PUB_SUBNET1 \
  --associate-public-ip-address \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=Nexus-Server}]" \
  --query "Instances[0].InstanceId" \
  --region us-east-1 \
  --output text)

echo " Nexus Server Instance ID: $NEXUS_ID"

# Launch EC2 Instance for SonarQube Server
SONARQUBE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --count 1 \
  --instance-type t3.medium \
  --key-name $KEY_NAME \
  --security-group-ids $SG_ID_3 \
  --subnet-id $PUB_SUBNET1 \
  --associate-public-ip-address \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=SonarQube-Server}]" \
  --query "Instances[0].InstanceId" \
  --region us-east-1 \
  --output text)

echo " SonarQube Server Instance ID: $SONARQUBE_ID"

aws ec2 describe-vpcs --vpc-ids $VPC_ID
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID"
aws ec2 describe-instances --instance-ids $JENKINS_ID
aws ec2 describe-instances --instance-ids $NEXUS_ID
aws ec2 describe-instances --instance-ids $SONARQUBE_ID

# Variables
JENKINS_IP="13.222.126.165"
KEY_NAME="jenkins-key"

# Navigate to PEM file location
cd ~/Downloads   # or the directory where you saved the PEM file

# Ensure proper permissions
chmod 400 ${KEY_NAME}.pem

# Connect to the Jenkins Server
ssh -i ${KEY_NAME}.pem ubuntu@${JENKINS_IP}

# Set Hostname
sudo hostname Jenkins-Server
sudo nano /etc/hostname - For permanent change

# Update System Packages
sudo apt update -y
sudo apt upgrade -y

# Run the following commands to install the latest AWS CLI v2:
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install
aws --version

# Run the following command to download and install the latest version of **eksctl**:
curl -sL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | sudo tar xz -C /usr/local/bin
eksctl version

# Run the following commands to download and install **kubectl** for Amazon EKS:
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" 
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client

# Update and install dependencies
sudo apt update -y
sudo apt install -y ca-certificates curl gnupg lsb-release

# Add Docker’s official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up Docker repo
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine, CLI, and Compose
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker
sudo systemctl enable docker
sudo systemctl start docker

# Verify Docker
docker --version
sudo docker run hello-world