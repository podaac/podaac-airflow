data "aws_eks_cluster" "cluster" {
  name = format(local.resource_name_prefix, "eks")
}

data "aws_iam_role" "cluster_iam_role" {
  name = "${format(local.resource_name_prefix, "eks")}-eks-node-role"
}

data "aws_ami" "al2_eks_optimized" {
  filter {
    name   = "image-id"
    values = [var.ami_image_id]
  }
  owners = ["863143145967"]
}

data "aws_vpc" "application_vpc" {
  tags = {
    "Name" : "Application VPC"
  }
}

data "aws_subnets" "private_application_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.application_vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["Private application*"]
  }
}