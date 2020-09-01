
See https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html for full guide.

It may take around 20 minutes to create/destroy all of the services.


## Setup

```sh
# setup kubectl
brew install kubernetes-cli

# setup aws-iam-authenticator
brew install aws-iam-authenticator
```


## Configuration

```sh
# save or append output in ~/.kube/config
terraform output kubeconfig >> ~/.kube/config
aws eks --region {region} update-kubeconfig --name terraform-eks-demo

# save output for configuration in Kubernetes
terraform output config-map-aws-auth > {config}.yml
kubectl apply -f {config}.yaml
```


## Running

```sh
kubectl get nodes

kubectl run demo --generator=run-pod/v1 --image=k8s.gcr.io/echoserver:1.4 --port=8080

# kubectl get deployments
kubectl get pods

# expose the pod
kubectl expose pod demo --type=LoadBalancer
# check cluster IP
kubectl get services

kubectl describe service/demo

# note that it may take several minutes for the Load Balancer to populate
curl {load_balancer_ip}:8080
```
