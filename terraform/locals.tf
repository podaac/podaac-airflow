
locals {
  resource_name_prefix   = join("-", compact([var.project, var.venue, "%s"]))
  dags_git_sync_branch   = var.dags_git_sync_branch != "" ? var.dags_git_sync_branch : (var.venue == "ops" ? "main" : var.venue)
}
