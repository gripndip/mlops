import argparse
import yaml
from omegaconf import OmegaConf
from s3_operations import download_from_s3
from train import train_model
import mlflow

def main(config_path: str):
    # Загрузка конфигурации
    config = OmegaConf.load(config_path)

    # Настройка MLflow
    mlflow.set_tracking_uri("http://localhost:5000")
    mlflow.set_experiment(config.experiment_name)

    # Загрузка данных из S3
    download_from_s3(config.bucket, config.input_key, "data.csv")

    # Запуск экспериментов с разными гиперпараметрами
    for params in config.hyperparameters_grid:
        with mlflow.start_run():
            train_model("data.csv", params)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--config', required=True, help='Path to config file')
    args = parser.parse_args()

    main(args.config)