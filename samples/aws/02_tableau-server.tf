module "tablea_server_on_aws" {
  source = "../../catalog/tableau-server-on-aws"
  name_prefix = "${var.project_shortname}-Tableau-"
  aws_region = var.aws_region
  num_linux_instances = 1
  num_windows_instances = 0
  c2_instance_type = "m4.4xlarge"
}
