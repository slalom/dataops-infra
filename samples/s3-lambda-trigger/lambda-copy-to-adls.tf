module "lambda_copy_to_adls" {

  # BOILERPLATE HEADER (NO NEED TO CHANGE):

  # TODO: Revert to master branch after feature merge:
  source = "../../components/aws/lambda-python"

  # TODO: Uncomment when added to module:
  name_prefix   = local.name_prefix
  resource_tags = local.project_tags
  # vpc_id          = module.vpc.vpc_id
  # public_subnets  = module.vpc.public_subnets
  # private_subnets = module.vpc.private_subnets

  # ADD OR MODIFY CONFIGURATION HERE:

  function_name = "fn_replicate_to_adls"
  source_root   = "${path.module}/resources/lambda/fn_replicate_to_adls"
  build_root    = "${path.module}/resources/build/fn_replicate_to_adls"
  handler       = "fn_replicate_to_adls.lambda_handler"
  environment_vars = {
    "ADLS_TARGET_ROOT" = "adls://my-acct/my-container/path/to/target/folder"
  }
  environment_secrets = {
  }
  triggering_s3_paths = [
    "s3://my-bucket/data/published/people-data/*"
  ]
  additional_tool_urls = {}

  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:



  */

}

# BOILERPLATE OUTPUT (NO NEED TO CHANGE):
output "lambda_copy_to_adls_summary" { value = module.lambda_copy_to_adls_summary.summary }
