
CONTAINER_KEYCLOAK := lab-keycloak
CONTAINER_GITLAB := lab-kc-gitlab

start:
	docker-compose up -d
	# wait for the KeyCloak to get ready
	sleep 120
	docker exec $(CONTAINER_KEYCLOAK) bash -c /tmp/init_keycloak.sh

end:
	docker-compose down

fetch_gitlab_pwd:
	docker exec -it $(CONTAINER_GITLAB) \
		bash -c \
		"cat /etc/gitlab/initial_root_password | grep 'Password:'"

gen_cert:
	bash generate_ssl_cert.sh

destroy: end
	docker rmi lab-keycloak:demo lab-kc-gitlab:demo

clean: destroy
	docker builder prune -a -f
	echo y | docker system prune
	rm -rf ./gitlab
