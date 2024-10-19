# AWS credentials
provider "aws" {
  region = "ap-southeast-1"
}
# Use variables declared in terraform.tfvars file
variable "avail_zone" {} 
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {}
variable "public_key_location" {}
variable "ssh_private_key" {}

# Create VPC
resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags       = {
    Name: "${var.env_prefix}-vpc"
  }
}

# Create subnet
resource "aws_subnet" "myapp-subnet-1" {
  vpc_id            = aws_vpc.myapp-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags              = {
    Name: "${var.env_prefix}-subnet-1"
  }
}
# Create Internet gateway
resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags   = {
    Name: "${var.env_prefix}-igw"
  }
}
# Create routing table
resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-main-rtb"
  }
}
# Create security group
resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name: "${var.env_prefix}-default-sg"
  }
}

# Query Amazone linux 2 AMI 
data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create ssh key pair using the local machine public key
resource "aws_key_pair" "ssh-key" {
  key_name   = "server-key"
  public_key = "${file(var.public_key_location)}"
}

# Create EC2 instance
resource "aws_instance" "myapp-server" {
  ami                         = data.aws_ami.latest-amazon-linux-image.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids      = [aws_default_security_group.default-sg.id]
  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh-key.key_name
  tags                        = {
    Name: "${var.env_prefix}-server"
  }
  # Execute the ansible playbook in the local machine
  #provisioner "local-exec" {
	#working_dir = "/home/jayce/ansible/docker-deployment-ec2-instance/"
	#command     = "ansible-playbook --inventory ${self.public_ip}, --private-key ${var.ssh_private_key} --user ec2-user deploy-docker-ec2-user.yml"
  #}
}

# Output EC2 public ip
output "ec2_public_ip" {
  value = aws_instance.myapp-server.public_ip
}

# Create null resource to execute the ansible playbook
resource "null_resource" "configure_server" {
  triggers = {
  trigger = aws_instance.myapp-server.public_ip
	}
	provisioner "local-exec" {
  working_dir = "/home/jayce/ansible/docker-deployment-ec2-instance/"
  command     = "ansible-playbook --inventory ${aws_instance.myapp-server.public_ip}, --private-key ${var.ssh_private_key} --user ec2-user deploy-docker-ec2-user.yml"
	}
}
