#!/bin/bash

# Сборка Docker образов
docker-compose build

# Запуск контейнеров
docker-compose up -d

# Создание бакетов в MinIO
mc config host add minio http://localhost:9000 minioadmin minioadmin
mc mb minio/datasets
mc mb minio/mlflow