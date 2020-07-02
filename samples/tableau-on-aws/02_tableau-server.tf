output "tableau_server_summary" { value = module.tableau_server_on_aws.summary }
module "tableau_server_on_aws" {
  # source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/tableau-server?ref=main"
  source        = "../../catalog/aws/tableau-server"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # CONFIGURE HERE:

  num_linux_instances   = 2
  num_windows_instances = 0
  registration_file     = "https://gist.githubusercontent.com/aaronsteers/11d857eeb78d52de125a9f04dac2d1bf/raw/899140b284628b49373cd7fa5fcd33636d0c7522/tableau-registration-aj.json"

  # Keypair is required to administer Linux instances via SSH:
  ssh_keypair_name         = module.admin_ssh_key_pair.key_name
  ssh_private_key_filepath = module.admin_ssh_key_pair.private_key_filename

  /*
  # OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  # Note: The smallest recommended instance size is m5.4xlarge
  ec2_instance_type = "m5.4xlarge"

  # Use smaller instance types for launch testing only. Warning: Install will
  # fail if the the instance type does not meet Tableau Server minimum specs.
  ec2_instance_type = "t3.medium"

  # Overrides the default firewall rules:
  admin_cidr        = []
  app_cidr          = ["0.0.0.0/0"]

  */
}
