# Secret folder (ignored by git)

After running `terraform apply` from the `prerun` directory, this folder should contain the following files:

- `dataops-prod-ec2keypair.pub`
- `dataops-prod-ec2keypair.pem`

NOTE:

- This folder is ignored by git and will not be committed to source control (except this `README.md` file)
- If you are using an environment created on another workstation, copy the files mentioned above into:
  1. this path (`.secrets`)
  2. your local .ssh folder (`~/.ssh`) or (`%USERPROFILE%/.ssh`)
