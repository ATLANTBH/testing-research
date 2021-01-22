# Additonal commands used for Kubernetes demo

## Setup before trying out demo examples
- Install and start Minikube
- Point docker build process to Minikube VM so that newly created docker images end up on the Minikube machine: 
```
eval $(minikube docker-env)
```
- Build two docker images (v1 and v2) from the source code in following way:
```
cd ../docker/node
vim server.js # change message that /ping endpoint retrieves to be: pong from version v1!
docker build -t abh/examplenode:v1 .
vim server.js # change message that /ping endpoint retrieves to be: pong from version v2!
docker build -t abh/examplenode:v2 .
```
This makes sures that we have two docker image versions of nodejs app which will be needed for the demo purposes


## HPA - Horizontal pod autoscaler

To try autoscaler, first make sure that number of app pods running = 1. Then create following HPA for demo purposes:
```
kubectl autoscale deployment myapp-dep --cpu-percent=10 --min=1 --max=3 -n bakir
```

Next, to provoke scaling to happen, run bash script `test_hpa.sh` in following fashion: 
```
bash test_hpa.sh -i <NODE_IP_ADDRESS> -p <NODE_PORT>
```
where, if you are running on Minikube, your NODE_IP_ADDRESS can be obtained from command `minikube ip` while your NODE_PORT is: 31123

In a minute, you should be able to see that scaling happened and number of pods = 3.

## Deployment rollout

First, deploy v1 version of the app with 3 pod replicas.
In the separate shell session, run folloing bash script `test_rollout.sh` to try the rolling update demo:
```
bash test_rollout.sh -i <NODE_IP_ADDRESS> -p <NODE_PORT>
```
where, if you are running on Minikube, your NODE_IP_ADDRESS can be obtained from command `minikube ip` while your NODE_PORT is: 31123

You will be able to see output like this: 
```
{"message":"pong from version v1! "}
{"message":"pong from version v1! "}
...
```

Next, run following command to change image version to v2:
```
kubectl set image deployment myapp-dep myapp=abh/examplenode:v2 -n bakir
```

In the opened shell session where `test_rollout.sh` is running, you will notice that output changes until you start getting responses only from v2 version which means that rollout was successful:
```
{"message":"pong from version v1! "}
{"message":"pong from version v1! "}
{"message":"pong from version v2! "}
{"message":"pong from version v1! "}
....
{"message":"pong from version v2! "}
{"message":"pong from version v2! "}
{"message":"pong from version v2! "}
```
Finally, observe the number of pods and use describe command for each pod to make sure that it is running version v2.