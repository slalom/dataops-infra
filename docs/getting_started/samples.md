---
parent: Getting Started
title: Running the Samples
has_children: false
nav_exclude: false
nav_order: 1
---
# QuickStart: Deploying Infrastructure Catalog Samples

_This guide is targeted towards developers and contributors. We will start with the
`data-lake-on-aws` sample, and from there then you can deploy any additional examples
using the same procedure._

## Setup workstation and clone the repo

1. Start by installing the required DataOps tools.
   - Go to [https://docs.dataops.tk/setup](https://docs.dataops.tk/setup).
   - Follow the provided installation steps, including at minimum:
     Git, Terraform, Docker, Visual Studio Code
2. Clone the `dataops-infra` repo.

## Configure credentials and deploy the sample

1. Create a new file in the `.secrets` folder called `aws-credentials` and enter your AWS
   credentials.
   - _For reference, copy the example file from `.template/aws-credentials.template`._
2. In left-hand navigation pane in VS Code, expand the `samples` folder select the
   `data-lake-on-aws` sample.
3. Right-click the desired sample folder (`data-lake-on-aws` in this example) and select
   "Open in Integrated Terminal".
4. Run `terraform init` to download needed providers and then run `terraform apply` to
   deploy the infrastructure.

## Tear down the infrastructure

1. Once again, in the left-hand navigation pane in VS Code, expand the `samples` folder
   select the `data-lake-on-aws` sample.
2. Right-click the desired sample folder (`data-lake-on-aws` in this example) and select
   "Open in Integrated Terminal".
3. Run `terraform destroy` to tear down the environment.
   - When prompted, type 'y' to confirm.

## Running additional samples

_Once you have successfully deployed the data lake sample, you are ready to deploy more
advanced infrastructures._

### Before you move forward

> Remember: you are deploying real infrastructure into the cloud, and those resources
> cost real money. Be sure to run `terraform destroy` to cleanup your AWS environment after
> running each deployment.

### Browsing the available samples

Navigate to the [samples directory](https://github.com/slalom-ggp/dataops-infra/tree/main/samples)
and select from one of the samples. Each sample folder has a README file which explains
the functionality and links to readme for each of the related catalog components.
