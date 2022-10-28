
dir_script = /app/script
container = lab-sql-server

.PHONY: start query stop

start:
	docker-compose up -d
	# wait for 30 seconds to have SQL Server ready
	sleep 30

init: start
	docker exec $(container) sh $(dir_script)/create.sh

query:
	docker exec $(container) sh $(dir_script)/query.sh "$(SQL)"

stop:
	docker-compose down
