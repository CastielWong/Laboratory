
CONTAINER_NAME := lab-kc-gitlab

start:
	docker-compose up -d

end:
	docker-compose down

fetch_gitlab_pwd:
	docker exec -it $(CONTAINER_NAME) \
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
