#!/bin/bash

ROOT="${PWD}/sample"
CONFIG="${ROOT}/configuration.json"
LOG="${ROOT}/demo.log"

SCRIPT_INIT="${ROOT}/scripts/init.sh"
CONFIG_UPDATED="${ROOT}/demo.json"

cat ${CONFIG} | sed "s#REPLACE#${SCRIPT_INIT}#" > ${CONFIG_UPDATED}

echo "Logs are writing to ${LOG} ..."
# output the building meesage to both console and a log
packer build -machine-readable ${CONFIG_UPDATED} 2>&1 | tee ${LOG}
# retrieve the AMI artifact from log
ARTIFACT=`cat ${LOG} | awk -F, '$0 ~/artifact,0,id/ {print $6}'`
echo "The AMI artifact is ${ARTIFACT}"

# extract the AMI identifier
AMI_ID=`echo ${ARTIFACT} | cut -d ':' -f2`
# write out to a tf so that the launch script is aware of the created AMI
echo "variable \"AMI_ID\" { default = \"${AMI_ID}\" }" > ${PWD}/demo.tf
