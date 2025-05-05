
This template is served for issue checking mainly, which can be used to investigate pods in the cluster
and should be a good place to start.


## Makefile
Utilize Makefile to simplify the checking:

| Receipt | Description                          |
|---------|--------------------------------------|
| launch  | start Minikube for K8S Cluster       |
| destroy | destroy everything and stop Minikube |
| init    | initialize namespace then switch     |
| start   | start up                             |
| end     | close down                           |
| run     | get to the container in the pod      |
