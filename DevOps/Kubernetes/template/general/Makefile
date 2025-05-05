
MANIFEST_CM:=cm.yaml
MANIFEST_DPL:=deploy.yaml
CK_NS:=cas-checking
CK_CON:=demo-con
CK_LABEL:=demo=check

start:
	kubectl apply -f $(MANIFEST_CM)
	kubectl apply -f $(MANIFEST_DPL)

end:
	kubectl delete -f $(MANIFEST_CM)
	kubectl delete -f $(MANIFEST_DPL)
	kubectl delete namespace $(CK_NS)

run:
	kubectl -n $(CK_NS) \
		exec -it $$(kubectl get pods -l $(CK_LABEL) -o jsonpath='{.items[0].metadata.name}') \
		-c $(CK_CON) \
		-- bash

launch:
	# minikube start --driver=hyperkit
	minikube start --driver=docker

init:
	kubectl get namespace $(CK_NS) || kubectl create namespace $(CK_NS)
	kubectl config set-context --current --namespace=$(CK_NS)

destroy:
	minikube stop
	minikube delete
