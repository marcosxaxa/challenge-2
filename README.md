# Deploying AWS resources with Terraform

# Requirements:

You will need:

1.  terraform - [Installation docs](https://learn.hashicorp.com/tutorials/terraform/install-cli)
2.  An AWS IAM user with at least **AmazonEC2FullAccess** and **AmazonVPCFullAccess** policies attached

## Credential profile configuration

:exclamation: #### Disclaimer
This terraform code uses a profile called **challenge** which, was configured using the following procedure:

[To install the AWS CLI version 2, see Installing, updating, and uninstalling the AWS CLI version 2](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)

After following the instructions on the above procedure, the profile configured should have the _same name_ in the **main.tf** file:

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

:warning: Hard-coded credentials are not recommended in any Terraform configuration and risk secret leakage should this file ever be committed to a public version control system.
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

Change into the terraform folder :

```
cd challenge-2/terraform
```

Inside this folder is all the files that terraform will use to deploy the resources to AWS. Use these commands:
Initialize the terraform project:

```
terraform init
```

Plan what terraform will deploy

```
terraform plan -var-file=var.tfvars
```

:exclamation: The **-var-file** parameter is necessary so terraform can read the values of the variables

Finally, to deploy the resources use this command:

```
terraform apply -var-file=var.tfvars
```

:grey_exclamation: Append the **-auto-approve** parameter to the command to apply automatically

## Accessing the webpage

This script displays a simple page showing how many tables there are on the database ec2 instance. The terraform script gives an IP as output. Accessing this IP on a browser will display the webpage.
