# ML Experiments Project
Проект для проведения экспериментов с ML моделями, используя W&B для трекинга и MinIO для хранения.

## Подготовка окружения
Установите Docker Desktop
Получите API ключ из W&B
## Структура проекта

├── lab3/
│   ├── scripts/
│   │   ├── train_model.py    # Скрипт обучения модели
│   │   └── run_experiment.bat # Скрипт запуска экспериментов
│   ├── config_grid.json      # Конфигурация гиперпараметров
│   └── titanic_processed.csv # Датасет
├── docker-compose.yml        # Конфигурация Docker services
├── Dockerfile               # Сборка Docker образа
├── requirements.txt         # Python зависимости
├── setup.bat               # Скрипт инициализации
└── .env                    # Переменные окружения
## Быстрый старт
### Создайте файл .env:

WANDB_API_KEY=your_wandb_api_key_here
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=Admin12345678

### Инициализируйте окружение:

setup.bat

### Запустите эксперименты:

lab3/scripts/run_experiment.bat lab3/config_grid.json experiment_name

# Мониторинг

W&B Dashboard: https://wandb.ai/
MinIO Console: http://localhost:9001
Локальные модели: папка output/