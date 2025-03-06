
IMAGE_NAME := lab-vault:demo
CONTAINER_NAME := demo-vault
VOLUME_NAME := lab-vault-data

start:
	docker-compose up -d

run:
	docker exec -it $(CONTAINER_NAME) bash

end:
	docker-compose down

clean: end
	echo y | docker system prune
	echo y | docker volume prune
	# docker volume rm $(VOLUME_NAME)

dismantle: clean
	docker rmi $(IMAGE_NAME)
