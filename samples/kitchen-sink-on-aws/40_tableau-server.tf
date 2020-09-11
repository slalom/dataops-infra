output "tableau_server_summmary" { value = module.tableau_server.summary }
module "tableau_server" {
  source = "../../catalog/aws/tableau-server"
  # source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/tableau-server?ref=main"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # CONFIGURE HERE:

  num_linux_instances   = 1
  num_windows_instances = 0
  registration_file     = "https://gist.githubusercontent.com/aaronsteers/11d857eeb78d52de125a9f04dac2d1bf/raw/899140b284628b49373cd7fa5fcd33636d0c7522/tableau-registration-aj.json"
  ec2_instance_type     = "t3.medium" # Largest instance allowed for https://playground.linuxacademy.com (doesn't meet Tableau minimum requirements)

  /*
  # OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  ec2_instance_type = "m5.4xlarge"
  admin_cidr        = []
  app_cidr          = ["0.0.0.0/0"]
  */
}
