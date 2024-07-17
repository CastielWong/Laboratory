
Use Terraform to create Kubernetes resources with Minikube.

## Prerequisite
Ensure both Terraform and Minikube are installed.
- Terraform: `brew install terraform`
- Minikube: `brew install minikube`
    - note Minikube utilizes Docker Desktop for runtime containers

## Usage
1. Launch Docker Desktop and start Minikube: `minikube start --vm-driver=hyperkit`
2. Download specified version of the K8S provider then initialize: `terraform init`
3. Display a list of resources to be created: `terraform plan`
4. Create K8S deployment:
```sh
terraform apply --auto-approve

# check all resources
kubectl get all -n demo-nginx

# verify the deployment is up
curl $(minikube ip):30201
```
5. Destroy the deployment: `terraform destroy --auto-approve`
