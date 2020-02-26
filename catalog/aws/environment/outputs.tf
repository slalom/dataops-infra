output "vpc_id" { value = var.disabled ? null : module.vpc.vpc_id }
output "private_subnets" {
  value = var.disabled || length(module.vpc.private_subnets) == 0 ? null : toset(module.vpc.private_subnets.*.id)
}
output "public_subnets" {
  value = var.disabled || length(module.vpc.public_subnets) == 0 ? null : toset(module.vpc.public_subnets.*.id)
}
output "environment" {
  # type = object({
  #   vpc_id          = string
  #   aws_region      = list(string)
  #   public_subnets  = list(string)
  #   private_subnets = list(string)
  # })
  value = {
    vpc_id          = module.vpc.vpc_id
    aws_region      = module.vpc.aws_region
    private_subnets = module.vpc.private_subnets
    public_subnets  = module.vpc.public_subnets
  }
}
