#!/bin/bash

# install [jq](https://stedolan.github.io/jq/) to parse JSON in command line
# the version used is 1.5
dnf install jq -y

export VARIABLES="${AIRFLOW_HOME}/variables.json"
export CONNECTIONS="${AIRFLOW_HOME}/connections.json"

# import variables
airflow variables import ${VARIABLES}

# import connections
if [ -d ${AIRFLOW_HOME} ]; then
    af_conn_add="airflow connections add"

    num_of_conns=$(cat ${CONNECTIONS} | jq '. | length')
    echo "Amount of connections: ${num_of_conns}"

    index=0
    while (( $index < $num_of_conns ))
    do
        # pass the index into jq syntax
        json_conn=$(cat ${CONNECTIONS} | jq '.[$i]' --argjson i ${index})

        args=" $(echo ${json_conn} | jq '.id')"

        items=("type" "description" "host" "schema" "login" "password" "port" "extra")
        for item in ${items[@]};
        do
            # retrieve the value of the item
            value=$(echo ${json_conn} | jq '.[$it]' --arg it ${item})

            # add only when such value is available
            if [ "${value}" != "null" ]; then
                args="${args} --conn-${item} ${value}"
            fi
        done

        # add the connection
        cmd_add_connection="${af_conn_add} ${args}"
        sh -c "${cmd_add_connection}"

        # move to next connection
        index=$(( index+1 ))
    done

fi

# start up webserver and at the background
airflow webserver > /dev/null 2>&1 &
airflow scheduler > /dev/null 2>&1 &

# monitor for commands to keep container running
exec "$@"
