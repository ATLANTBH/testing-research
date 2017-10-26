# Jenkins slave reconnect mechanism

## About

This simple script is used to check and reconnect jenkins slave with jenkins master (using JNLP) if connection fails for some reason. Common scenario where this might be needed is if you have jenkins master running in the cloud (ex. aws) and you have node machine located in your own data center (for example, you need to connect macosx slave machine from your datacenter to jenkins master hosted on aws)

## Motivation behind

We encountered occasional issues with connecting slave machine to jenkins master where process that is keeping the connection alive would die after couple of days. That is why we needed a mechanism that would periodically check if process is running and if not, it would run it again. Of course, obvious candidate for solving this problem is bash script that will be executed in crontab

## How to use it

1. Open crontab using crontab -e command:
2. Add command in crontab: 
```
nohup /bin/bash <PATH>/jenkins_slave_reconnect.sh ${JENKINS_MASTER_URL} ${NODE_NAME} ${SECRET} ${OUTPUT_LOG_FILE} &
```
3. Set desired frequency for execution. For example (run this script once per day):
```
* * 1 * * nohup /bin/bash <PATH>/jenkins_slave_reconnect.sh ${JENKINS_MASTER_URL} ${NODE_NAME} ${SECRET} ${OUTPUT_LOG_FILE} &
```
4. (optional) You can provide additional parameter to the script above ${PROTOCOL} (as last parameter) if you run your jenkins instance without ssl (which is not recommended). Otherwise, script will use https by default