#VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "EKS-vpc"
  cidr = var.vpc_cidr

  azs            = data.aws_availability_zones.available.names
  public_subnets = var.public_subnet_cidr
  private_subnets = var.private_subnet_cidr
  enable_dns_hostnames = true
  enable_nat_gateway     = true
  single_nat_gateway     = true


  tags = {
 "kubernetes.io/cluster/my-eks-cluster" = "shared" 
  }
  public_subnet_tags = {
    
 "kubernetes.io/cluster/my-eks-cluster" = "shared"
 "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
 "kubernetes.io/cluster/my-eks-cluster" = "shared"
  "kubernetes.io/role/internal-elb" = "1"
 }

} 




module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "my-cluster"
  kubernetes_version = "1.33"

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
  }

 
  endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.xlarge"]

      min_size     = 2
      max_size     = 10
      desired_size = 2
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}




