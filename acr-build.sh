#!/bin/bash

TAG=flask-demo

if [[ ! -v REGISTRY ]]; then
  echo "Set \$REGISTRY before running this script"
  exit 1
fi

az acr build -t ${TAG} -r ${REGISTRY} .
