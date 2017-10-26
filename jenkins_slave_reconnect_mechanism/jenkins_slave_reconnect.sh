#!/bin/bash
PATH=/usr/local/bin:/usr/local/sbin:~/bin:/usr/bin:/bin:/usr/sbin:/sbin

JENKINS_MASTER_URL=$1
NODE_NAME=$2
TOKEN=$3
OUTPUT_FILE=$4
PROTOCOL=${5:-https}

ps -ef | grep "${PROTOCOL}://${JENKINS_MASTER_URL}/computer/${NODE_NAME}/slave-agent.jnlp" | grep slave.jar
if [[ $? != 0 ]]; then
  echo "Jenkins slave: ${NODE_NAME} is not connected to jenkins master: ${JENKINS_MASTER_URL}"
  echo "Connecting it again..."
  nohup java -jar slave.jar -jnlpUrl ${PROTOCOL}://${JENKINS_MASTER_URL}/computer/${NODE_NAME}/slave-agent.jnlp -secret ${TOKEN} >> $OUTPUT_FILE &
else
  echo "Jenkins slave: ${NODE_NAME} is already connected to jenkins master: ${JENKINS_MASTER_URL}"
fi