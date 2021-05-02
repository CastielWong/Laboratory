#!/bin/bash
bash init.sh

airflow scheduler

# monitor for commands to keep container running
exec "$@"
