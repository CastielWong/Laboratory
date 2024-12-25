
ENV_FILE := /home/.env

gen_token:
	bash script/generate_access_token.sh

pyiceberg:
	python run_with_pyiceberg.py

pyspark: gen_token
	export $$(grep -v '^#' ${ENV_FILE} | xargs) && python run_with_pyspark.py

check: gen_token
	export $$(grep -v '^#' ${ENV_FILE} | xargs) && python check_data.py
