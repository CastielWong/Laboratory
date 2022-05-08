
- [Recommended Setup](#recommended-setup)
- [Common Command](#common-command)
- [API](#api)

## Recommended Setup
Below is the recommended setup to initialize shell environment, for which can be placed to somewhere like "~/.bashrc":
```sh
# enable kubectl command auto completion
source <(kubectl completion bash)

# make alias and enable completion the same time
alias k="kubectl"
complete -F __start_kubectl k

alias kn="kubectl config set-context --current --namespace"
alias ktmp_chk="kubectl run tmp --image=nginx:alpine --restart=Never --rm -i -- wget -O- -T 5 -t 2"

export now="--force --grace-period 0"
export do="--dry-run=client -o yaml"
```


## Common Command
```sh
kubectl version

kubectl describe nodes {node}

kubectl get all
kubectl get namespaces
kubectl get quota
kubectl get events --all-namespaces

kubectl get pods --all-namespaces
kubectl get pods --show-labels
kubectl get pod {pod} -o [yaml|wide]
kubectl get deployments,svc,rs,po -l {label_key}={label_value}

kubectl edit deployment {name}

kubectl api-resources

kubectl create -f {template}

kubectl label pod -l {existed_key}={existed_val} {new_key}={new_val}
kubectl annotate po -l {label_key}={label_val} {annotate_key}={annotate_val}

kubectl cluster-info

kubectl config view
kubectl config use-context {user}@{host}
kubectl config set-context --current --namespace={namespace}

kubectl get [cm | configmap | networkpolicy | secret | pv | pvc | statefulset | sts]

kubectl -n {namespace} get roles


kubectl logs -f --tail 200 {pod}

kubectl exec -it {pod} -c {container} -- /bin/bash

# access to http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
kubectl proxy
# set the proxy running at background
kubectl proxy &
jobs fg

# monitor pods
watch kubectl get pods -o wide

kubectl create deployment {name} --{container}={image}
kubectl describe deployment {name}
kubectl scale deployment {name} --replicas={n}
kubectl set image deployment {name} {container}={image}
kubectl rollout history deployment {name} --revision={i}
kubectl rollout undo deployment {name} --to-revision={i}

kubectl expose deployment {deployment-name} --name={service-name} --type={service-type}

# watch the pod
kubectl get pod {pod-name} -w

kubectl apply -f <config>.yaml
kubectl delete -f {config}.yaml

kubectl create configmap {cm-name} \
    --from-literal={key1}={value1} \
    --from-literal={key2}={value2}

kubectl create secret generic {secret-name} \
    --from-literal={key}={value}

kubectl exec {name} -- /bin/sh -c 'cat /usr/share/nginx/html/index.html'
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
