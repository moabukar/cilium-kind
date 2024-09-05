#!/bin/bash

echo -e '\n[BOOSTRAPING CLUSTER]\n'
kind create cluster --config=./conf.yaml

# Fails on errors
set -o errexit
