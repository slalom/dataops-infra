/*
* Airflow is an open source platform to programmatically author, schedule and monitor workflows. More information here: [airflow.apache.org](https://airflow.apache.org/)
*
*/

locals {
  airflow_url = "http://${module.airflow_ecs_task.load_balancer_dns}:8080"
}

module "airflow_ecs_cluster" {
  source        = "../../../components/aws/ecs-cluster"
  name_prefix   = var.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags
}

module "airflow_ecs_task" {
  source              = "../../../components/aws/ecs-task"
  name_prefix         = var.name_prefix
  environment         = var.environment
  resource_tags       = var.resource_tags
  use_fargate         = true
  ecs_cluster_name    = module.airflow_ecs_cluster.ecs_cluster_name
  container_image     = var.container_image
  container_num_cores = var.container_num_cores
  container_ram_gb    = var.container_ram_gb
  admin_ports         = ["8080"]
  always_on           = true
  use_load_balancer   = true
}
