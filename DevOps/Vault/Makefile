
IMAGE_NAME := lab-vault:demo
CONTAINER_NAME := demo-vault
VOLUME_NAME := lab-vault-data

start:
	docker-compose up -d

end:
	docker-compose down

run:
	docker exec -it $(CONTAINER_NAME) bash

credential:
	docker logs $(CONTAINER_NAME) 2>&1 | grep -niE "unseal key:|root token:"

clean: end
	rm -rf tmp_data/
	echo y | docker system prune
	echo y | docker volume prune
	# docker volume rm $(VOLUME_NAME)

dismantle: clean
	docker rmi $(IMAGE_NAME)
