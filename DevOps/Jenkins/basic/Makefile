
CONTAINER_JENKINS := lab-jenkins

start:
	docker-compose up -d

run:
	docker exec -it $(CONTAINER_JENKINS) bash

stop:
	docker-compose down

clean:
	echo y | docker system prune
