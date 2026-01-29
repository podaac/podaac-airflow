terraform {
  backend "s3" {}
}

resource "kubernetes_namespace" "service_area" {
  metadata {
    name = var.service_area
  }
}

module "unity-sps-database" {
  source       = "./modules/terraform-unity-sps-database"
  project      = var.project
  venue        = var.venue
  service_area = var.service_area
  release      = var.release
}

module "unity-sps-efs" {
  source       = "./modules/terraform-unity-sps-efs"
  project      = var.project
  venue        = var.venue
  service_area = var.service_area
  release      = var.release
}

module "unity-sps-karpenter-node-config" {
  source                 = "./modules/terraform-unity-sps-karpenter-node-config"
  project                = var.project
  venue                  = var.venue
  service_area           = var.service_area
  release                = var.release
  kubeconfig_filepath    = var.kubeconfig_filepath
  ami_image_id           = data.aws_ssm_parameter.eks_ami.value
  karpenter_node_classes = var.karpenter_node_classes
  karpenter_node_pools   = var.karpenter_node_pools
}

module "unity-sps-airflow" {
  source                     = "./modules/terraform-unity-sps-airflow"
  project                    = var.project
  venue                      = var.venue
  service_area               = var.service_area
  release                    = var.release
  kubeconfig_filepath        = var.kubeconfig_filepath
  kubernetes_namespace       = kubernetes_namespace.service_area.metadata[0].name
  db_instance_identifier     = module.unity-sps-database.db_instance_identifier
  db_secret_arn              = module.unity-sps-database.db_secret_arn
  efs_file_system_id         = module.unity-sps-efs.file_system_id
  airflow_webserver_username = var.airflow_webserver_username
  docker_images              = var.airflow_docker_images
  helm_charts                = var.helm_charts
  ssl_certificate_arn        = var.ssl_certificate_arn
  airflow_state_bucket       = var.airflow_state_bucket
}
