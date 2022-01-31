
Create the directory before creating the volume:
```sh
minikube ssh

mkdir pod-volume
cd pod-volume/

exit
```

Then run:
```sh
kubectl apply -f shared-pod.yaml

kubectl expose pod shared-pod --type=NodePort --port=80

kubectl get services,endpoints

minikube service shared-pod

kubectl delete pod shared-pod
# no corresponding endpoint
kubectl get services,endpoints


kubectl apply -f check-pod.yaml
# the endpoint is newly created
kubectl get services,endpoints

minikube service shared-pod
```
