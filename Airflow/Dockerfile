FROM apache/airflow:2.0.0-python3.8

USER root

# default env variables which have already been set in base image
ARG AIRFLOW_USER_HOME=/home/airflow
ARG AIRFLOW_HOME=/opt/airflow

ARG gid=root
ARG uid=airflow

# variables for dockerize
ARG DOCKERIZE_VERSION=v0.6.1

ARG FERNET_KEY="79sdBbVNxAOL6SDRBX9vERxnaNaKkZ_lE3Sv3iofRLQ="
ARG SECRET_KEY="iPHOs79dyFQiYEfX2aq9TQ=="

ARG TEMPLATE_AIRFLOW_CONFIG="airflow.cfg.tmpl"
ARG AIRFLOW_SMTP_MAIL_FROM="airflow@example.com"
# postgres
ARG POSTGRES_HOST="172.18.0.2"
ARG POSTGRES_PORT="5432"
ARG POSTGRES_DB="airflow"
ARG POSTGRES_USERNAME="airflow"
ARG POSTGRES_PASSWORD="airflow"
# redis
ARG REDIS_HOST="172.18.0.3"
ARG REDIS_PORT="6379"

ARG SCRIPT_HOME="${AIRFLOW_HOME}/scripts"


# install software package needed
RUN apt-get update \
  && apt-get install -y vim wget
# remove package list
RUN rm -rf /var/lib/apt/lists/*

# install dockerize
RUN wget https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz \
    && rm dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz

# dockerize utilizes "{{:}}" for template variables by default, the same applied for default "airflow.cfg"
# switch to "<%:%>" in the config template for the purpose of distinction
COPY templates/${TEMPLATE_AIRFLOW_CONFIG} ${AIRFLOW_HOME}/${TEMPLATE_AIRFLOW_CONFIG}
# apply dockerize to render the template
RUN dockerize -delims "<%:%>" -template ${AIRFLOW_HOME}/${TEMPLATE_AIRFLOW_CONFIG}:${AIRFLOW_HOME}/airflow.cfg
RUN rm ${AIRFLOW_HOME}/${TEMPLATE_AIRFLOW_CONFIG}

# prepare scripts
COPY --chown=${uid}:${gid} ./entrypoint.sh ${SCRIPT_HOME}/
RUN chmod 755 ${SCRIPT_HOME}/entrypoint.sh

USER ${uid}

WORKDIR ${AIRFLOW_HOME}

ENTRYPOINT ["./scripts/entrypoint.sh"]
