
CONTAINER_CODER := lab-coder
VOLUME_CODER := lab-coder-db

start:
	docker-compose --env-file env.sh up -d

run:
	docker exec -it $(CONTAINER_CODER) bash

stop:
	docker-compose --env-file env.sh down

clean:
	echo y | docker system prune
	docker volume rm $(VOLUME_CODER)
