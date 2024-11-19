
CONTAINER_CODER := lab-coder
VOLUME_CODER := lab_coder_db

start:
	docker-compose --env-file env.sh up -d

run:
	docker exec -it $(CONTAINER_CODER) bash

end:
	docker-compose --env-file env.sh down

clean:
	echo y | docker system prune
	docker volume rm $(VOLUME_CODER)
