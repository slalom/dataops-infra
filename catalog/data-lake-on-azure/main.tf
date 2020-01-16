module "data_lake" {
  source            = "../../modules/azure/storage"
  resource_group    = var.resource_group
  project_shortname = var.project_shortname
}
module "network" {
  source            = "../../modules/azure/network"
  resource_group    = var.resource_group
  project_shortname = var.project_shortname
}
