module "data_lake_with_lambda_trigger" {

  # BOILERPLATE HEADER (NO NEED TO CHANGE):

  # TODO: Revert to master branch after feature merge:
  source = "../../catalog/aws/data-lake"

  # TODO: Uncomment when added to module:
  name_prefix   = local.name_prefix
  resource_tags = local.project_tags
  # vpc_id          = module.vpc.vpc_id
  # public_subnets  = module.vpc.public_subnets
  # private_subnets = module.vpc.private_subnets

  # ADD OR MODIFY CONFIGURATION HERE:

  lambda_python_source          = "${path.module}/python/fn_lambda_logger"
  s3_triggers = [{
    # triggering_path  = "data/published/people-data/*"
    triggering_path  = "uploads/*"
    function_name    = "fn_lambda_logger2"
    function_handler = "main.lambda_handler"
    environment_vars = {}
    environment_secrets = {
      "PGP_PRIVATE_KEY" = "aws:secretmanager/myaccount/mysecret"
    }
  }]

  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:



  */

}

# BOILERPLATE OUTPUT (NO NEED TO CHANGE):
output "data_lake_summary" { value = module.data_lake_with_lambda_trigger.summary }
