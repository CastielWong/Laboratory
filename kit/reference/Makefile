
IMAGE_NAME := lab-<tem>:demo
CONTAINER_NAME := demo-<tech>
VOLUME_NAME := lab-<tech>-vol

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
