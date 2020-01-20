
module "airflow_vpc" {
  source      = "../../modules/aws/vpc"
  name_prefix = var.name_prefix
}

module "airflow_server" {
  source                   = "../../modules/aws/ecs"
  name_prefix              = var.name_prefix
  aws_region               = var.aws_region
  num_instances            = var.num_linux_instances
  container_name           = "${var.name_prefix}-Airflow"
  container_num_cores      = var.container_num_cores
  container_ram_gb         = var.container_ram_gb
  admin_ports              = { "WebPortal" : 8080 }
  app_ports                = {}
  vpc_id                   = module.airflow_vpc.vpc_id
  subnet_id                = coalescelist(module.airflow_vpc.public_subnet_ids, [""])[0]
  # subnet_id              = coalescelist(module.airflow_vpc.private_subnet_ids, [""])[0]
}
