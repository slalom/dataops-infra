module "dynamodb" {
  source        = "../../../components/aws/dynamodb"
  name_prefix   = var.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags

  billing_mode = "PAY_PER_REQUEST"
  primary_key  = "modelName"
}
