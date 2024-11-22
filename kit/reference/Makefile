
CONTAINER_NAME := lab-<tech>
VOLUME_NAME := lab-<tech>-vol

start:
	docker-compose up -d

run:
	docker exec -it $(CONTAINER_NAME) bash

stop:
	docker-compose down

clean:
	echo y | docker system prune
	docker volume rm $(VOLUME_NAME)
