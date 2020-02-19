# Solution Module Samples

Sample modules are essentially just solution modules which test a certain combination of Infrastructure Catalog features, and which can be copy-pasted into external projects.

## How to use these samples in external projects

To export a sample solution to an external project, follow these steps:

1. Create a folder called `infra` in the root the directory of your project, and then paste the desired sample into that new folder.
2. Create a new file in the parent folder called `infra-config.yml` following the example [here](infra-config.yml).
3. Create a folder called `.secrets` at the root of your project.
    * **IMPORTANT:** Make sure you add .secrets to the top of your `.gitignore` fire.
4. For AWS projects, create a file in `.secrets` called `credentials` and then paste in your AWS credentials following the guidelines [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).
5. Within each .tf files you copy into your project, replace `source = "../../catalog/{...}"` at the top of the file with `source = "git::https://github.com/slalom-ggp/dataops-infra.git///catalog/{...}?ref=master"`. This changes the source from a local module reference to a remote git reference.

## Testing Sample Modules

In order to receive automated testing, each sample folder needs to registered in the file [.github/workflows/onpush.yml](.github/../../.github/workflows/onpush.yml). To do this, simply open the `onpush.yml` file, search for the text `sample-id:` and add the name of the sample folder to the list.
