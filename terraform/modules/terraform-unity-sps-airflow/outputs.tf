output "airflow_deployed_dags_pvc" {
  value = kubernetes_persistent_volume_claim.airflow_deployed_dags.metadata[0].name
}
