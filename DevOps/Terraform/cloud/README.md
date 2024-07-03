
- [Credential](#credential)
- [AWS](#aws)
  - [Verification](#verification)
- [Azure](#azure)
- [GCP](#gcp)
  - [Verification](#verification-1)

This directory to keep common infrastructure used among clouds.


When create a new configuration — or check out an existing configuration from version
control — it's needed to initialize the directory with `terraform init`.


```sh
terraform fmt
terraform validate

terraform apply -var-file="<value>.tfvars"

terraform show

terraform state list

terraform destroy
```


## Credential
Generate SSH key:
```sh
ssh-keygen -t rsa -b 2048 -f "~/.ssh/id_demo_<vendor>"

chmod 400 "~/.ssh/id_demo_<vendor>"
```

For AWS:
- by default, credential is stored in: "$HOME/.aws/credentials"
- generate the Access Key and Secret in https://us-east-1.console.aws.amazon.com/iam/home#/security_credentials

For GCP:
- by default, credential is stored in: "$HOME/.config/gcloud/application_default_credentials.json"
- reset the whole configuration by removing "$HOME/.config/gcloud" then `gcloud init`
- run `gcloud auth application-default login` for the credential
- copy the default credential to elsewhere then set `GOOGLE_APPLICATION_CREDENTIALS` to it
- set `gcloud auth application-default set-quota-project <project_id>`


## AWS
Ensure:
- AWS CLI `aws` is installed
- AWS account and associated credentials allowed to create resources

Service provided:
- EC2
  - Key Pair: need to generate it locally beforehand and have it updated
  - Security Group
- IAM: User, Policy, Role
- VPC: Subnet, Internet Gateway, Route Table
- S3
  - Bucket Policy

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

az account set --subscription "<subscription_id>"

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<subscription_id>"
```


## GCP
Ensure:
- GCP CLI `gcloud` is installed

Service provided:
- Compute Instance
- Compute Network: Subnetwork, Router, Router NAT, Firewall


```sh
gcloud auth application-default login
```

### Verification
- Computer Instance: check the instance is up and running
    - access via `ssh -i ~/.ssh/<private_key> dev@<public_ip>`


`gcloud` is another way connecting to the VM:
```sh
# login GCP before any further operations
gcloud auth login
# set up project
gcloud config set project "<project_id>"

# ssh to the instance to verify the connection
gcloud compute ssh "<instance-name>" --zone="<zone>"
```
