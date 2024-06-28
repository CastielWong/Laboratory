
This directory to keep common infrastructure used among clouds.


When create a new configuration — or check out an existing configuration from version
control — it's needed to initialize the directory with `terraform init`.


```sh
terraform fmt
terraform validate

terraform apply

terraform show

terraform state list

terraform destroy
```

## AWS
Ensure:
- AWS CLI is installed
- AWS account and associated credentials allowed to create resources

Service provided:
- EC2
  - Key Pair: need to generate it locally beforehand and have it updated
  - Security Group
- IAM: User, Policy, Role
- VPC: Subnet, Internet Gateway, Route Table
- S3
  - Bucket Policy

### Credential
By default, its configuration directory is: "$HOME/.aws/"

https://us-east-1.console.aws.amazon.com/iam/home#/security_credentials

### Verification
- EC2: check the instance is up and running
    - access via `ssh -i ~/.ssh/<private_key> ec2-user@<public_ip>`
    - verify associated components:
        - Key Pair
        - Security Group
        - IAM Role
        - VPC
        - Subnet: public IP provided
- VPC: verify connection between components
    - Subnet, Route Table, Internet Gateway
- S3: bucket is available
- IAM: verify User is assumed by the Role via Policy
    - User, Role, Policy
    - Role with User has Policy (permission) attached
    - User has Policy (assuming) attached with Role

## Azure
Ensure Azure CLI is installed.

```sh
# find the id of subscription
az login

az account set --subscription "{subscription_id}"

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<subscription_id>"
```

### GCP
Ensure gcloud CLI is installed.

```sh
gcloud auth application-default login

```
