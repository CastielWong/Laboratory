
CONTAINER_NAME := lab-kc-gitlab

start:
	docker-compose up -d

fetch_gitlab_pwd:
	docker exec -it $(CONTAINER_NAME) \
		bash -c \
		"cat /etc/gitlab/initial_root_password | grep 'Password:'"

end:
	docker-compose down

clean:
	echo y | docker system prune
	rm -rf ./gitlab
