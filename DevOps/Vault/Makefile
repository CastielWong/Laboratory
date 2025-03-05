
CONTAINER_NAME := lab-vault
VOLUME_NAME := lab-vault-data

start:
	docker-compose up -d

run:
	docker exec -it $(CONTAINER_NAME) sh

stop:
	docker-compose down

clean:
	echo y | docker system prune
	echo y | docker volume prune
	docker volume rm $(VOLUME_NAME)
