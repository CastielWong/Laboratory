
run:
	echo "AIRFLOW_UID=$(shell id -u)" > .env
	docker-compose up -d

stop:
	docker-compose down
	docker volume rm airflow-local-postgres
