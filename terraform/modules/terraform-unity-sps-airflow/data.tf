data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = format(local.resource_name_prefix, "eks")
}

data "aws_vpc" "cluster_vpc" {
  id = data.aws_eks_cluster.cluster.vpc_config[0].vpc_id
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


data "kubernetes_namespace" "service_area" {
  metadata {
    name = var.kubernetes_namespace
  }
}

/* Note: comment this out remove  access via the JPL network*/
data "kubernetes_ingress_v1" "airflow_ingress" {
  metadata {
    name      = kubernetes_ingress_v1.airflow_ingress.metadata[0].name
    namespace = data.kubernetes_namespace.service_area.metadata[0].name
  }
}

/* Note: re-enable this to allow access via the public internet
data "kubernetes_ingress_v1" "airflow_ingress_internal" {
  metadata {
    name      = kubernetes_ingress_v1.airflow_ingress_internal.metadata[0].name
    namespace = data.kubernetes_namespace.service_area.metadata[0].name
  }
} */

data "aws_db_instance" "db" {
  db_instance_identifier = var.db_instance_identifier
}

data "aws_secretsmanager_secret_version" "db" {
  secret_id = var.db_secret_arn
}

data "aws_efs_file_system" "efs" {
  file_system_id = var.efs_file_system_id
}


