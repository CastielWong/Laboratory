
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
- IAM
- VPN
- S3

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
