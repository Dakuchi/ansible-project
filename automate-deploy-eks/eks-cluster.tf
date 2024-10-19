provider "kubernetes" {
  config_path            = false
  host                   = data.aws_eks_cluster.myapp-cluster.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.myapp-cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.myapp-cluster.certificate_authority.0.data)
}

data "aws_eks_cluster" "myapp-cluster" {
  depends_on = [module.eks]
  name       = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "myapp-cluster" {
  depends_on = [module.eks]
  name       = module.eks.cluster_name
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.24.3"
  cluster_name    = "myapp-eks-cluster"
  cluster_version = "1.30"
  subnet_ids      = module.myapp-vpc.private_subnets
  vpc_id          = module.myapp-vpc.vpc_id
  tags            = {
    environment = "development"
    application = "myapp"
  }
  self_managed_node_groups = [
    {
        instance_type        = "t2.micro"
        launch_template_name = "worker-group-1"
        desired_capacity     = 2
    },
    {
        instance_type        = "t2.micro"
        launch_template_name = "worker-group-2"
        desired_capacity     = 1
    }
  ]
}

output "aws_eks_cluster" {
  value = module.eks
}