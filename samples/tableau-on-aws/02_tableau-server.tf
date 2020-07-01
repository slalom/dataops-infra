module "tableau_server_on_aws" {
  # source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/tableau-server?ref=master"
  source        = "../../catalog/aws/tableau-server"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # CONFIGURE HERE:

  num_linux_instances   = 0
  num_windows_instances = 0

  /*
  # OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  # Note: The smallest recommended instance size is m4.4xlarge
  ec2_instance_type = "m4.4xlarge"

  # Use smaller instance types for launch testing only. Warning: Install will
  # fail if the the instance type does not meet Tableau Server minimum specs.
  ec2_instance_type = "t3.medium"

  # Overrides the default firewall rules:
  admin_cidr        = []
  app_cidr          = ["0.0.0.0/0"]

  # An SSH key pair is required if you need to log into the instance:
  ssh_public_key_filepath  = "path/to/some-key.pub"
  ssh_private_key_filepath = "path/to/some-key.pem"

  */
}

output "summmary" { value = module.tableau_server_on_aws.summary }
