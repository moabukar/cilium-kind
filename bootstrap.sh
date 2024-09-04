#!/bin/bash

echo -e '\n[BOOSTRAPING CLUSTER]\n'
kind create cluster --config=./kind-config.yaml

# Fails on errors
set -o errexit
