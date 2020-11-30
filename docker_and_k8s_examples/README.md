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

1. [Dockerfile.v1](https://github.com/ATLANTBH/testing-research/blob/master/docker_and_k8s_examples/docker/node/dockerfile_examples/Dockerfile.v1) - Starting example which shows how to package express/nodejs app into the docker image and how to use parent node image which contains all pre-installed libs necessary for running this app. Alpine distro is used to shrink the size of the docker image

  Usage:
  ```
  $ cd ./node
  $ cp dockerfile_examples/Dockerfile.v1 Dockerfile
  $ docker build -t abh/examplenode .
  ```

  To run this example, we will use docker-compose in following way:
  ```
  $ docker-compose build
  $ docker-compose up -d
  ```

  This should deploy express/nodejs app as well as mongo db backend to which web app is connecting. 
  You should be able to view the app in browser by accessing: `http://localhost:8081`

2. [Dockerfile.v2](https://github.com/ATLANTBH/testing-research/blob/master/docker_and_k8s_examples/docker/node/dockerfile_examples/Dockerfile.v2) - Example of dockerized express/nodejs app which shows what we need to do when we want to install some processing linux libs and how it increases size of the final image.

  Usage:
  ```
  $ cd ./node
  $ cp dockerfile_examples/Dockerfile.v2 Dockerfile
  $ docker build -t abh/examplenode .
  $ docker images | grep abh/examplenode
  abh/examplenode                                    latest                                 44b39dff7a55        2 seconds ago       119MB
  ```

  As you see, size of the image is 119MB. This example doesn't use multi-stage build pattern which will be demonstrated in `Dockerfile.v3`

3. [Dockerfile.v3](https://github.com/ATLANTBH/testing-research/blob/master/docker_and_k8s_examples/docker/node/dockerfile_examples/Dockerfile.v3) - Example of dockerized express/nodejs app which shows how to utilise multi-stage build pattern to shrink the size of your final docker image.

  Usage:
  ```
  $ cd ./node
  $ cp dockerfile_examples/Dockerfile.v3 Dockerfile
  $ docker build -t abh/examplenode .
  $ docker images | grep abh/examplenode
  abh/examplenode                                    latest                                 f64455321390        2 seconds ago       99.7MB
  ```

  As you see, size of the image is now 99.7MB which is 20MB less than previous example

