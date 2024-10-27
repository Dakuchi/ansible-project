# Ansible and Terraform Automation Projects

This repository contains Ansible and Terraform projects that automate various infrastructure and application deployment tasks. Each project is tailored for specific use cases, including deploying services on AWS, managing Kubernetes clusters, and setting up Docker environments.

## Projects Overview

### 1. `nodejs_deployment`

This project installs Node.js and runs a Node.js application on a target server. It ensures that the application is up and running with necessary configurations.

- **Features**:
  - Installs Node.js on the target server.
  - Deploys and runs the Node.js application.

### 2. `nexus_deployment`

Automates the entire process of deploying a Nexus repository server. This project configures Nexus as a local proxy for various development artifacts, allowing efficient access and storage.

- **Features**:
  - Sets up the Nexus server, including downloading and installing required packages.
  - Configures Nexus for secure access, user permissions, and repository management.

### 3. `automate-deploy-eks`

This project sets up and configures an Amazon Elastic Kubernetes Service (EKS) cluster using Terraform and Ansible. It includes network configuration, Kubernetes namespace creation, and application deployment.

- **Features**:
  - **Terraform**: Sets up a VPC and provisions an EKS cluster with 2 self-managed node groups.
  - **Ansible**: 
    - Uses the Kubernetes provider to interact with the EKS cluster.
    - Creates a new Kubernetes namespace.
    - Deploys an Nginx deployment in the newly created namespace.

### 4. `docker-deployment-ec2-instance`

This project integrates Ansible and Terraform to automate the provisioning and configuration of Docker containers on an AWS EC2 instance. It includes different methods for deploying containers based on user permissions and roles.

- **Features**:
  - **Terraform**: Provisions a new EC2 instance with necessary components.
  - **Ansible**:
    - Deploys Docker containers from Docker Hub using Docker Compose.
    - Supports deployment using the default `ec2-user`.
    - Supports deployment with a newly created user.
    - Implements Ansible roles for structured playbook organization.

### 5. `dynamic-inventory`

Leverages Ansible’s dynamic inventory with `aws_ec2` to deploy Docker containers from Docker Hub. This project dynamically identifies EC2 instances in AWS based on tags or other attributes.

- **Features**:
  - Uses `aws_ec2` for dynamic inventory, allowing flexible and scalable deployments.
  - Deploys Docker containers from Docker Hub to dynamically identified instances.

## Getting Started

Each project has been structured independently, allowing you to explore the functionality of each automation scenario.

### Prerequisites

- **Ansible**: Ensure Ansible is installed on your local machine.
- **Terraform**: Install Terraform for infrastructure provisioning tasks.
- **AWS CLI**: Required for deploying resources to AWS.
- **Boto3**: Required for dynamic inventory with AWS EC2.

### Usage

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/Dakuchi/ansible-project.git
