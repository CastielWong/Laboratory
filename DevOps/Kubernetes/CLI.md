
## Common Command

```sh
kubectl version
kubectl get pods --all-namespaces
kubectl get namespaces
kubectl get deployments, rs, po -l {label_key}={label_value}

kubectl cluster-info

kubectl config view
kubectl config use-context {user}@{host}
kubectl config set-context --current --namespace={space}

kubectl get [sts | pvc | cm | configmap | statefulset | statefulsets]

kubectl -n {namespace} get roles


kubectl logs -f --tail 200 {pod}

kubectl exec -it {pod} -- bash

# access to http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
kubectl proxy
# set the proxy running at background
kubectl proxy &
jobs fg

# monitor pods
watch kubectl get pods -o wide

kubectl create deployment {name} --{container}={image}
kubectl scale deploy {name} --replicas={n}
kubectl describe deployment {name}
kubectl set image deployment {name} {container}={image}
kubectl rollout history deploy {name} --revision={i}
kubectl rollout undo deployment {name} --to-revision={i}



```

Usual path to explore:
- http://localhost:8081/api/v1
- http://localhost:8081/apis/apps/v1
- http://localhost:8081/healthz
- http://localhost:8081/metrics


## API

Get the authentication:

```sh
TOKEN=$(kubectl describe secret -n kube-system $(kubectl get secrets -n kube-system | grep default | cut -f1 -d ' ') | grep -E '^token' | cut -f2 -d':' | tr -d '\t' | tr -d " ")

APISERVER=$(kubectl config view | grep https | cut -f 2- -d ":" | tr -d " ")

echo $TOKEN
echo $APISERVER

curl $APISERVER --header "Authorization: Bearer $TOKEN" --insecure

curl $APISERVER --cert encoded-cert --key encoded-key --cacert encoded-ca
```
