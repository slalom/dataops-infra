# Secrets directory (ignored by Git)

**Note:**

* To prevent accidentally committing secrets into source control, all files in this directory except this one (`README.md`) will be **excluded** from git. (Do not store any actual secrets in this readme file.)

## Sample AWS credentials file

```text
[{{project_shortname}}-terraform]

aws_access_key_id={{access_key}}
aws_secret_access_key={{secret_key}}
```

## Sample secrets file for terraform

`aws-secrets-manager-secrets.yml`

```yml
# Secrets stored here (`aws-secrets-manager-secrets.yml`) will automatically be deployed to AWS Secrets Manager.
# Secrets will be created in secret manager as follows:
#           arn:aws:secretsmanager:us-east-2::secret:MY-APP-ID-ygkLPL

APPLICATION_A:
 USERNAME: my-username
 PASSWORD: my-pass

APPLICATION_B:
 USERNAME: my-username
 PASSWORD: my-pass
 API_KEY: my-api-key

SIMPLE_SECRET: foobar

# Notes:
#  - The header name becomes the name of the secret and is automatically concatenated with a random string in the ARN
#  - Simple secrets will simply be encoded as strings
#  - Secrets with multiple values will be stored as JSON, as in this example:
#       `{ "USERNAME": "foo", "PASSWORD": "bar" }`
```
