module "airflow_ecs_cluster" {
  source      = "../../../modules/aws/ecs-cluster"
  name_prefix = local.name_prefix
  aws_region  = var.aws_region
}

module "airflow_ecs_task" {
  source              = "../../../modules/aws/ecs-task"
  name_prefix         = local.name_prefix
  aws_region          = var.aws_region
  use_fargate         = true
  ecs_cluster_name    = module.airflow_ecs_cluster.ecs_cluster_name
  container_image     = var.container_image
  container_num_cores = var.container_num_cores
  container_ram_gb    = var.container_ram_gb
  admin_ports         = ["8080"]
  app_ports           = ["8080"]
  vpc_id              = local.vpc_id
  public_subnets      = local.public_subnets
  private_subnets     = local.private_subnets
  always_on           = true
  use_load_balancer   = true
}
