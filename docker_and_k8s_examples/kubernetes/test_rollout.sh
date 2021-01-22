#!/bin/bash

while getopts ":i:p:" opt; do
    case $opt in
        i) NODE_IP_ADDRESS=$OPTARG ;;
        p) NODE_PORT=$OPTARG ;;
    esac
done

while true; do
    curl -X GET http://${NODE_IP_ADDRESS}:${NODE_PORT}/ping; echo
    sleep 1
done