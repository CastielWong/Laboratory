
VAULT_NS := demo-vault
VAULT_RELEASE_VERSION := 0.30.0
DIR_SCRIPT := ../scripts
SCRIPTS = generate.sh export_all.sh
ENV_FILE = tmp.env

# =============================================================================
# setup and teardown
launch:
	# minikube start --driver=hyperkit
	minikube start --driver=docker

init:
	kubectl get namespace $(VAULT_NS) || kubectl create namespace $(VAULT_NS)

end:
	helm -n $(VAULT_NS) uninstall vault

clean: end
	kubectl delete namespace $(VAULT_NS)

destroy: clean
	minikube stop
	minikube delete
# =============================================================================
# K8S setting
set-namespace:
	kubectl config set-context --current --namespace=$(VAULT_NS)

get-vault-ui:
	minikube -n ${VAULT_NS} service vault-ui --url &

forward-vault-ui:
	# access via localhost:8200
	kubectl port-forward -n ${VAULT_NS} svc/vault-ui 8200:8200 &> /dev/null &
# =============================================================================
# vault running
start-dev: init
	helm install vault hashicorp/vault \
		--namespace $(VAULT_NS) \
		--version $(VAULT_RELEASE_VERSION) \
		--set='server.dev.enabled=true' \
		--set='ui.enabled=true' \
		--set='ui.serviceType=LoadBalancer'

start-prd: init
	helm install vault hashicorp/vault \
		--namespace $(VAULT_NS) \
		--version $(VAULT_RELEASE_VERSION) \
		--set='server.ha.enabled=true' \
		--set='server.ha.raft.enabled=true' \
		--set='server.ha.raft.replicas=3'

run:
	kubectl -n $(VAULT_NS) exec -it vault-0 -- sh

retrieve-root-token:
	kubectl logs -n $(VAULT_NS) vault-0 | grep "Root Token"
# =============================================================================
# vault configuration
set-env:
	echo "export VAULT_ADDR='http://127.0.0.1:8200'" > $(ENV_FILE)
	echo "export VAULT_TOKEN=$$(kubectl logs -n demo-vault vault-0 | grep 'Root Token:' | awk '{print $$3}')" >> $(ENV_FILE)
	echo "export VAULT_DIR_MIGRATION='tmp_migration'" >> $(ENV_FILE)

generate-items:
	# source $(ENV_FILE) && bash $(DIR_SCRIPT)/generate.sh
	source $(ENV_FILE) && bash $(DIR_SCRIPT)/generate_policy.sh

export-items:
	source $(ENV_FILE) && bash $(DIR_SCRIPT)/export_main.sh
	source $(ENV_FILE) && bash $(DIR_SCRIPT)/export_auth_method.sh

import-items:
	source $(ENV_FILE) && bash $(DIR_SCRIPT)/import_main.sh
	# source $(ENV_FILE) && bash $(DIR_SCRIPT)/import_auth_method.sh
