---
parent: Getting Started
title: Running the Samples
has_children: false
nav_exclude: false
nav_order: 1
---
# QuickStart: Deploying Infrastructure Catalog Samples

_This guide is targeted towards developers, contributors, or anyone who wants to test
out the various modules which available. We will start with the
[Data Lake Sample](https://github.com/slalom-ggp/dataops-infra/tree/main/samples/data-lake-on-aws) on AWS, and from there then you can deploy any additional examples
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
   - _For reference, refer to the sample file: `.secrets/aws-credentials.template`._
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

## Running the 'kitchen sink' sample

_Once you have successfully deployed the data lake sample, you are ready to deploy more
advanced infrastructures. This section will walk you through deploying the
[Kitchen Sink Sample](https://github.com/slalom-ggp/dataops-infra/tree/main/samples/kitchen-sink-on-aws)
on AWS._

> **Before you go further:**
>
> Some of these components require python, and now's a good time to pause and double
> check that python and it's installer "pip" are both working as expected. In any command line try
> running `pip3 --version`. If that doesn't work, you can try `pip --version`. If that doesn't work,
> please revisit the [datapops quickstart](https://docs.dataops.tk/setup) and follow the
> instructions to re-install python (after first uninstalling any versions you already have
> installed). Similarly, you can double check that terraform is installed by running
> `terraform --version` on any command line prompt.
>
> And one more thing.... remember that you are deploying _**real infrastructure**_ into the cloud,
> an those resources cost _**real money**_. Be sure to run `terraform destroy` to cleanup your AWS
> environment after running each deployment. Alternatively, you can also use an environment like
> [LinuxAcademy Playground](https://playground.linuxacademy.com) which automically cleans up your
> resources after a specified time limit.

Once you are ready to go:

1. In left-hand navigation pane in VS Code, expand the `samples` folder select the
   `kitcken-sink-on-aws` sample.
2. Right-click the `kitcken-sink-on-aws` sample folder and select
   "Open in Integrated Terminal".
3. Run `terraform init` to download needed providers and then run `terraform apply` to
   deploy the infrastructure.
   - If needed, perform any necessary debugging until you succeed in running `terraform apply`
     without errors. At any time, especially if you get stuck on a particular module, you may still be
     able to run `terraform output`, which will give you an overview of the components which have
     deployed successfully.
4. Your deployed infrastructure should look similar to the below.
   [![Diagram](../../samples/kitchen-sink-on-aws/diagram.png)](../../samples/kitchen-sink-on-aws/diagram.png)
5. **Important:** Once you are done, run `terraform destroy` to destroy the infrastructure which
   you have deployed.

### Browsing the deployed infrastructure

Navigate to the [samples directory](https://github.com/slalom-ggp/dataops-infra/tree/main/samples)
and select from one of the samples. Each sample folder has a README file which explains
the functionality and links to readme for each of the related catalog components.
