## Providers

| Name | Version |
|------|---------|
| archive | n/a |
| aws | n/a |
| null | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| environment | n/a | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| name\_prefix | n/a | `string` | n/a | yes |
| resource\_tags | n/a | `map(string)` | n/a | yes |
| s3\_path\_to\_lambda\_zip | S3 Path to where the source code zip should be uploaded. | `string` | n/a | yes |
| s3\_trigger\_bucket | variable "dependency\_urls" { description = "If additional files should be packaged into the source code zip, please provide map of relative target paths to their respective download URLs." type        = map(string) default     = {} } | `string` | n/a | yes |
| lambda\_source\_folder | Local path to a folder containing the lambda source code | `string` | `"resources/fn_log"` | no |
| pip\_path | n/a | `string` | `"pip3"` | no |
| runtime | n/a | `string` | `"python3.8"` | no |
| s3\_triggers | n/a | <pre>map(object({<br>    # function_name       = string<br>    triggering_path     = string<br>    function_handler    = string<br>    environment_vars    = map(string)<br>    environment_secrets = map(string)<br>  }))</pre> | <pre>{<br>  "fn_log": {<br>    "environment_secrets": {},<br>    "environment_vars": {},<br>    "function_handler": "main.lambda_handler",<br>    "triggering_path": "*"<br>  }<br>}</pre> | no |
| timeout\_seconds | n/a | `number` | `300` | no |

## Outputs

| Name | Description |
|------|-------------|
| build\_temp\_dir | n/a |

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
