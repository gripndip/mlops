setup:
        poetry install
        poetry shell

run-docker:
        docker-compose up -d

stop-docker:
        docker-compose down

train:
        poetry run python train.py --data_path ./data/titanic.csv --hyperparams ./hyperparameters.yaml

check:
        poetry run pre-commit run --all-files