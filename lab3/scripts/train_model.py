import os
import argparse
import itertools
import json

import joblib
import pandas as pd
import wandb
import boto3
from botocore.client import Config
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.model_selection import train_test_split

def get_s3_client():
    """Создание клиента S3 (MinIO)"""
    return boto3.client(
        's3',
        endpoint_url=os.getenv('MINIO_ENDPOINT', 'http://minio:9000'),
        aws_access_key_id=os.getenv('MINIO_ROOT_USER', 'admin'),
        aws_secret_access_key=os.getenv('MINIO_ROOT_PASSWORD', 'Admin12345678'),
        config=Config(signature_version='s3v4'),
        region_name='us-east-1'
    )

def train_and_log(config, dataset_path, experiment_name):
    if not isinstance(config, dict):
        raise TypeError(f"Invalid config type: {type(config)}. Expected dict.")

    # Проверка WANDB_API_KEY
    if not os.getenv('WANDB_API_KEY'):
        raise ValueError("WANDB_API_KEY not set in environment variables")

    # Явный вызов wandb.login()
    wandb.login(key=os.getenv('WANDB_API_KEY'))

    # Инициализация S3 клиента
    s3_client = get_s3_client()
    bucket = 'models'

    try:
        s3_client.head_bucket(Bucket=bucket)
    except:
        try:
            s3_client.create_bucket(Bucket=bucket)
        except Exception as e:
            print(f"Warning: Could not create bucket: {e}")

    # Загрузка данных
    data = pd.read_csv(dataset_path)
    X = data.iloc[:, :-1]
    y = data.iloc[:, -1]
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # Генерация всех возможных комбинаций параметров
    param_combinations = list(itertools.product(*config.values()))

    # Для каждой комбинации параметров обучаем модель
    for params in param_combinations:
        model_config = dict(zip(config.keys(), params))
        print(f"Training with config: {model_config}")

        try:
            # Инициализация W&B с уникальным именем для каждого эксперимента
            experiment_name_unique = f"{experiment_name}_{'_'.join(map(str, params))}"
            wandb.init(
                project="ml_experiments",
                config=model_config,
                name=experiment_name_unique,
                reinit=True
            )

            model = RandomForestRegressor(**model_config)
            model.fit(X_train, y_train)

            # Предсказания и метрики
            predictions = model.predict(X_test)
            mae = mean_absolute_error(y_test, predictions)
            mse = mean_squared_error(y_test, predictions)
            r2 = r2_score(y_test, predictions)

            # Логирование метрик в W&B
            wandb.log({"MAE": mae, "MSE": mse, "R2": r2})

            # Сохранение модели локально
            model_filename = f"{experiment_name_unique}_model.pkl"
            model_path = f"output/{model_filename}"
            joblib.dump(model, model_path)
            print(f"Model saved locally to {model_path}")

            # Загрузка модели в S3
            try:
                s3_key = f"models/{experiment_name_unique}/{model_filename}"
                s3_client.upload_file(model_path, bucket, s3_key)
                print(f"Model uploaded to S3: {s3_key}")
            except Exception as e:
                print(f"Warning: Failed to upload model to S3: {e}")

        except Exception as e:
            print(f"Error in experiment {experiment_name_unique}: {e}")
            raise
        finally:
            wandb.finish()

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", type=str, required=True, help="Path to config JSON")
    parser.add_argument("--dataset", type=str, required=True, help="Dataset path")
    parser.add_argument("--experiment", type=str, required=True, help="Experiment name")
    args = parser.parse_args()

    with open(args.config) as f:
        config = json.load(f)

    train_and_log(config, args.dataset, args.experiment)