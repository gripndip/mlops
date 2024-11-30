#!/bin/bash

CONFIG_PATH=$1

# Запуск экспериментов
docker run --network=mlops_default \
    -v $(pwd):/app \
    -e MLFLOW_TRACKING_URI=http://mlflow:5000 \
    mlops-experiments \
    --config $CONFIG_PATH