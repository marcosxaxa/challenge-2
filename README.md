# Deploying AWS resources with Terraform

# Requirements:

You will need:

1.  Terraform - [Installation docs](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2.  An _AWS IAM_ user with programmatic access and at least **AmazonEC2FullAccess** and **AmazonVPCFullAccess** policies attached

## Credential profile configuration

:exclamation: This Terraform code uses a profile called **challenge** which, was configured using the following procedure:

[To install the AWS CLI version 2, see Installing, updating, and uninstalling the AWS CLI version 2](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)

After following the instructions on the above procedure, the profile configured should have the _same name_ in the **profile** parameter in the **main.tf** file. Change it as needed.

### Shared Credentials File

You can use AWS credentials or a configuration file to specify your credentials. The default location is $HOME/.aws/credentials on Linux and macOS, or "%USERPROFILE%\.aws\credentials" on Windows. You can optionally specify a different location in the Terraform configuration by providing the shared_credentials_file argument or using the AWS_SHARED_CREDENTIALS_FILE environment variable. This method also supports a profile configuration and matching AWS_PROFILE environment variable:

Usage:

```

provider "aws" {
    region = "us-west-2"
    profile = "challenge"
}

```

## Static Credentials

:warning: Hard-coded credentials are not recommended in any Terraform configuration and, it risks secrets leakage should this file ever be committed to a public version control system.
Static credentials can be provided by adding an access_key and secret_key in-line in the AWS provider block:

Usage:

```

provider "aws" {
region = "us-west-2"
access_key = "my-access-key"
secret_key = "my-secret-key"
}

```

## Cloning the project

Clone the git project to your workstation with the following command:

```

git clone https://github.com/marcosxaxa/challenge-2.git

```

## Creating the resources

Change into the Terraform folder :

```

cd challenge-2/terraform

```

Inside this folder is all the files that Terraform will use to deploy the resources to AWS. Use these commands:
Initialize the Terraform project:

```

terraform init

```

Plan what Terraform will deploy

```

terraform plan -var-file=var.tfvars

```

:exclamation: The **-var-file** parameter is necessary so Terraform can read the values of the variables

Finally, to deploy the resources use this command:

```

terraform apply -var-file=var.tfvars -auto-approve

```

:grey_exclamation: The **-auto-approve** parameter is to apply automatically.

## Accessing the webpage

When deployed, the Terraform script gives an IP as output. Accessing this IP on a browser will display a simple page showing how many tables are on the database in the ec2 instance.

## Cleaning up

To delete the resources previously created, you can use the following command:

```
terraform destroy -var-file=var.tfvars -auto-approve
```
