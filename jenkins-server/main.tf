#VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc"
  cidr = var.vpc_cidr

  azs            = data.aws_availability_zones.available.names
  public_subnets = var.public_subnet_cidr

  enable_dns_hostnames = true

  tags = {
    Name        = "jenkins-vpc"
    Terraform   = "true"
    Environment = "dev"
  }
}

#Sg


module "security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins-sg"
  description = "Jenkins security group"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = {
    jenkins_http = {
      from_port   = 8080
      to_port     = 8080
      ip_protocol = "tcp"
      description = "HTTP"
      cidr_ipv4   = "0.0.0.0/0"
    }
    ssh = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      description = "SSH"
      cidr_ipv4   = "0.0.0.0/0" # Replace with your IP range
    }
  }

  egress_rules = {
    all_outbound = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all outbound traffic"
    }
  }

  tags = {
    Name        = "jenkins-sg"
    Environment = "dev"
  }
}

#EC2 INSTANCE
module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "JENKINS-SERVER"

  instance_type               = "t3.micro"
  key_name                    = "jenkins-server-key"
  ami                         = data.aws_ami.example.id
  monitoring                  = true
  vpc_security_group_ids      = [module.security_group.id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true # Added: Forces creation of a Public IPv4 address
  user_data                   = file("jenkins-install.sh")
  availability_zone           = data.aws_availability_zones.available.names[0]

  tags = {
    Name        = "JENKINS-SERVER"
    Terraform   = "true"
    Environment = "dev"
  }
}

