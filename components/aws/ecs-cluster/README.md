## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| environment | n/a | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| name\_prefix | n/a | `string` | n/a | yes |
| ec2\_instance\_count | n/a | `number` | `0` | no |
| ec2\_instance\_type | n/a | `string` | `"m4.xlarge"` | no |
| resource\_tags | n/a | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| ecs\_cluster\_arn | n/a |
| ecs\_cluster\_name | n/a |
| ecs\_instance\_role | n/a |

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
