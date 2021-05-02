#!/bin/bash
bash init.sh

airflow celery flower

# monitor for commands to keep container running
exec "$@"
