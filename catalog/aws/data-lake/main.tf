data "aws_region" "current" {}

locals {
  aws_region = var.aws_region != null ? var.aws_region : data.aws_region.current.name
}
