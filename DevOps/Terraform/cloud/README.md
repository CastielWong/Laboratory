
- [Credential](#credential)
- [AWS](#aws)
  - [Verification](#verification)
- [Azure](#azure)
  - [Service Principal](#service-principal)
  - [Verification](#verification-1)
- [GCP](#gcp)
  - [Verification](#verification-2)

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
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_demo_{vendor}

chmod 400 ~/.ssh/id_demo_{vendor}
```

For AWS:
- by default, credential is stored in: "$HOME/.aws/credentials"
- generate the Access Key and Secret in https://us-east-1.console.aws.amazon.com/iam/home#/security_credentials

For Azure:
- by default, the subscription is stored in: "$HOME/.azure/clouds.config"
- a Service Principal is required to create for
  - `ARM_CLIENT_ID`
  - `ARM_CLIENT_SECRET`
  - `ARM_TENANT_ID`

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

To enable Terraform to launch up AWS:
```sh
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
```

### Verification
- EC2: check the instance is up and running
    - access via `ssh -i ~/.ssh/<private_key> <user_name>@<public_ip>`
        - when the `user_name` is wrong, error "Received disconnect from \<public_ip\> port 22:2: Too many authentication failures" would occur even the credential is correct
        - the `user_name` for default AWS images is "ec2-user"
        - for all the other images, need to check the image for more info
        - popular `user_name` can be: "root", "admin", "ubuntu", etc.
    - verify the Apache server is up with website via its IP address
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
Ensure:
- Azure CLI `az` is installed
- a Service Principal is created for Terraform to deploy services

Service provided:
- Virtual Machine

### Service Principal
To manage the Service Principal on Azure portal:
- search for "subscription"
- select the corresponding subscription
- check "Access control (IAM)"
- select "Role assignments" tab to list roles available

Create a proper [role](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#role-based-access-control-administrator) to create services:
```sh
# find the subscription id
az login

# set up with the subscription
az account set --subscription "${ARM_SUBSCRIPTION_ID}"

# create RBAC as "Owner" is dangerous and not encouraged
az ad sp create-for-rbac --role="Owner" --scopes="/subscriptions/${ARM_SUBSCRIPTION_ID}"

# show the role created
az ad sp show --id ${ARM_CLIENT_ID}
# delete the role
az ad sp delete --id ${ARM_CLIENT_ID}
```

### Verification
Note that the storage attached (`storage_os_disk`) to VM OS would be required to
delete manually as Azure would keep the storage even when its attached VM is destroyed.

- Resource Group:
  - Terraform, the one created to contain all services created
  - Network Watcher, would be created by the system implicitly if not
- Virtual Machine: check the instance is up and running
    - access via `ssh -i ~/.ssh/<private_key> developer@<public_ip>`
    - verify the Apache server is up with website via its IP address
        - note that Azure needs the start-up script to wait for VM get ready
    - verify associated components:
        - Disk: OS Disk, Managed Disk
        - Network Interface: public IP provided
- Public IP: connect with Network Interface and the VM
- Virtual Network: verify Subnet inclusion
- Network Security Group: enable SSH connection with the Subnet
- Storage Account: bucket is available
- User Assigned Identity:
  - Role Assignment to Resource Group
  - Role Assignment to Storage Account
- Network Watcher: linked with the Resource Group of Network Watcher

Note that logs can be found "/var/log/cloud-init.log "or "/var/log/cloud-init-output.log"
for investigation.

## GCP
Ensure:
- GCP CLI `gcloud` is installed

Service provided:
- Compute Instance
- Compute Network: Subnetwork, Router, Router NAT, Firewall
- Storage Bucket

To enable Terraform to launch up GCP:
```sh
gcloud auth application-default login
```

### Verification
- Computer Instance: check the instance is up and running
    - access via `ssh -i ~/.ssh/<private_key> developer@<public_ip>`
    - verify the Apache server is up with website via its IP address
    - verify associated components:
        - Service Account
        - Compute Network
        - Compute Subnetwork: public IP provided
- Compute Network: verify connection between components
    - Compute Subnetwork, Compute Router, Compute NAT, Compute Firewall
- Storage Bucket: bucket is available

`gcloud` is another way connecting to the VM:
```sh
# login GCP before any further operations
gcloud auth login
# set up project
gcloud config set project "<project_id>"

# ssh to the instance to verify the connection
gcloud compute ssh "<instance-name>" --zone="<zone>"
```
