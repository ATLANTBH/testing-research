#!/bin/bash

while getopts ":i:p:" opt; do
    case $opt in
        i) NODE_IP_ADDRESS=$OPTARG ;;
        p) NODE_PORT=$OPTARG ;;
    esac
done

while true; do
    curl -X POST -H "Content-Type: application/json" -d '{"first_name": "John", "last_name": "Doe", "age": "34"}' http://${NODE_IP_ADDRESS}:${NODE_PORT}/employee; echo
done
