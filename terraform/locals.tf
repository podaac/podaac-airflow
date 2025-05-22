
locals {
  resource_name_prefix = join("-", compact([var.project, var.venue, "%s"]))
}
