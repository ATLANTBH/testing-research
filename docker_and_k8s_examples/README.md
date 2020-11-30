# Docker and K8s examples

## What is this? 

Set of docker and k8s related examples used for demo purposes

## Docker examples

They are divided into two sections: `bash` (examples where bash script is executed in docker container) and `node` (example where nodejs script is executed in docker container). Following examples exist:

### Bash

1. [Dockerfile.v1](https://github.com/ATLANTBH/testing-research/blob/master/docker_and_k8s_examples/docker/bash/dockerfile_examples/Dockerfile.v1) - Starting example which shows anatomy of simple Dockerfile with purposely left room for improvements

  Usage:
  ```
  $ cd ./bash
  $ cp dockerfile_examples/Dockerfile.v1 Dockerfile
  $ docker build -t abh/examplebash .
  $ docker run abh/examplebash
  ```

2. [Dockerfile.v2](https://github.com/ATLANTBH/testing-research/blob/master/docker_and_k8s_examples/docker/bash/dockerfile_examples/Dockerfile.v2) - Improvement on Dockerfile.v1 where ordering of commands is fixed to speed up building of docker image by paying attention to the layers + used lightweight distro parent image (alpine)

  Usage:
  ```
  $ cd ./bash
  $ cp dockerfile_examples/Dockerfile.v2 Dockerfile
  $ docker build -t abh/examplebash .
  $ docker run abh/examplebash
  ```

3. [Dockerfile.v3](https://github.com/ATLANTBH/testing-research/blob/master/docker_and_k8s_examples/docker/bash/dockerfile_examples/Dockerfile.v3) - In case you want to debug what happens in your container when created from image, you can override your ENTRYPOINT with sleep command. Note that you should run this example in background mode with (-d) flag

  Usage:
  ```
  $ cd ./bash
  $ cp dockerfile_examples/Dockerfile.v3 Dockerfile
  $ docker build -t abh/examplebash .
  $ docker run -d abh/examplebash

  $ docker ps -a | grep "abh/examplebash"
  ed511ba108f0        abh/examplebash                             "sleep 1000000"          13 seconds ago       Up 12 seconds

  $ docker exec -it ed511ba108f0 sh
  /myscripts # ls
  example_1.sh
  ```

  When you entered into the container, you can execute script by yourself:
  ```
  /myscripts # sh example_1.sh -n Test
  This is Test
  ```

4. [Dockerfile.v4](https://github.com/ATLANTBH/testing-research/blob/master/docker_and_k8s_examples/docker/bash/dockerfile_examples/Dockerfile.v4) - In case you want to parametrise entrypoint, this example shows how to use ENV var. It also demonstrates how you can persist data accross multiple runs of docker container using volumes.

  Script `example_2.sh` has following line:
  ```
  echo "This is ${NAME}" >> /output/out.txt
  ```
  which shows that we will persist data (in append fashion) to location IN container `/output/out.txt` every time we run container. Without specifying a volume, this data will be lost when we start container again. Therefore, we use volume which basically mounts specific directory from the hostOS to specific directory in container.

  Usage:
  ```
  $ cd ./bash
  $ mkdir output # this is the location on hostOS where we will persist data across multiple runs
  $ cp dockerfile_examples/Dockerfile.v4 Dockerfile
  $ docker build -t abh/examplebash .
  $ docker run -v <FULL_PATH_TO_CLONED_GIT_REPO>/docker_and_k8s_examples/docker/bash/output:/output -e name=FirstTest abh/examplebash
  $ docker run -v <FULL_PATH_TO_CLONED_GIT_REPO>/docker_and_k8s_examples/docker/bash/output:/output -e name=SecondTest abh/examplebash
  ```

  Check the persisted data on hostOS:
  ```
  $ cat output/out.txt
  This is FirstTest
  This is SecondTest
  ```

### Node

1. [Dockerfile](https://github.com/ATLANTBH/testing-research/docker_and_k8s_examples/docker/node/Dockerfile) - Starting example which shows how to package express nodejs/mongodb app into the docker images and how to use parent node image which has all pre-installed libs necessary to run this app. Alpine distro is used to shrink the size of the docker image. This example is meant to be used in docker-compose fashion. That being said, do following to use it:

Usage:
```
$ cd ./node
$ docker-compose build
$ docker-compose up -d
```

You should be able to view the app in browser by accessing: `http://localhost:8081`