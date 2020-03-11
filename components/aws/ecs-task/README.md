
# AWS ECS-Task

`/components/aws/ecs-task`

## Overview


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| container\_command | n/a | `any` | n/a | yes |
| container\_entrypoint | n/a | `any` | n/a | yes |
| container\_image | e.g. [aws\_account\_id].dkr.ecr.[aws\_region].amazonaws.com/[repo\_name] | `any` | n/a | yes |
| ecs\_cluster\_name | n/a | `string` | n/a | yes |
| environment | n/a | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| load\_balancer\_arn | n/a | `string` | n/a | yes |
| name\_prefix | n/a | `string` | n/a | yes |
| secrets\_manager\_kms\_key\_id | n/a | `string` | n/a | yes |
| use\_fargate | n/a | `bool` | n/a | yes |
| admin\_ports | n/a | `list(string)` | <pre>[<br>  "8080"<br>]</pre> | no |
| always\_on | n/a | `bool` | `false` | no |
| app\_ports | n/a | `list(string)` | <pre>[<br>  "8080"<br>]</pre> | no |
| container\_name | n/a | `string` | `"DefaultContainer"` | no |
| container\_num\_cores | n/a | `string` | `"4"` | no |
| container\_ram\_gb | n/a | `string` | `"8"` | no |
| ecs\_launch\_type | 'FARGATE' or 'Standard' | `string` | `"FARGATE"` | no |
| environment\_secrets | Mapping of environment variable names to secret manager ARNs or local file secrets. Examples:  - arn:aws:secretsmanager:[aws\_region]:[aws\_account]:secret:prod/ECSRunner/AWS\_SECRET\_ACCESS\_KEY  - path/to/file.json:MY\_KEY\_NAME\_1  - path/to/file.yml:MY\_KEY\_NAME\_2 | `map(string)` | `{}` | no |
| environment\_vars | Mapping of environment variable names to their values. | `map(string)` | `{}` | no |
| resource\_tags | n/a | `map(string)` | `{}` | no |
| schedules | A lists of scheduled execution times. | `set(string)` | `[]` | no |
| use\_load\_balancer | n/a | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| ecs\_checklogs\_cli | n/a |
| ecs\_container\_name | n/a |
| ecs\_logging\_url | n/a |
| ecs\_runtask\_cli | n/a |
| ecs\_security\_group | n/a |
| ecs\_task\_name | n/a |
| load\_balancer\_arn | n/a |
| load\_balancer\_dns | n/a |

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
