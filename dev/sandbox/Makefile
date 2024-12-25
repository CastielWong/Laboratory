
CONTAINER_NAME := sandbox
DIR_VOLUME := sandbox_vol

start:
	docker-compose up -d

run:
	docker exec -it $(CONTAINER_NAME) bash

end:
	docker-compose down

clean: end
	echo y | docker system prune
	rm -rf $(DIR_VOLUME)/
