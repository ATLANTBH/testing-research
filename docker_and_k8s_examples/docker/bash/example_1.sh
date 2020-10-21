#!/bin/sh
# Basic helper script for demonstration of Docker concepts

while getopts ":n:" opt; do
    case $opt in
        n) NAME=$OPTARG ;;
    esac
done

echo "This is ${NAME}"