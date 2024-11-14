
CONTAINER_CODER := lab-coder

start:
	docker-compose --env-file env.sh up -d

run:
	docker exec -it $(CONTAINER_CODER) bash

stop:
	docker-compose --env-file env.sh down

clean:
	echo y | docker system prune
