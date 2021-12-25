
Make sure "mongo-secret.yaml" is applied before "mongo.yaml".
Make sure "mongo-configmap.yaml" is applied before "mongo-express.yaml".

Run `minikube service <service-name>`

Mongo Express External Service
-> Mongo Express Pod
-> Mongo DB Internal Service
-> Mongo DB Pod
