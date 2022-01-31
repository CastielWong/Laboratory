
The order to apply each YAML doesn't matter, since the `selector` in "webserver-svc.yaml" would match the server in "webserver.yaml".

Find out the local IP via `minikube ip`, then find `kubectl get service` or describe the service `kubectl describe service web-service` for the port number.

Or run `minikube service web-service` directly to access the application.


## Reference
- How To Change Nginx index.html in Kubernetes With Configmap: https://scriptcrunch.com/change-nginx-index-configmap/
