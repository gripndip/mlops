# Dockerfile
FROM python:3.9-slim

# Установка необходимых системных зависимостей
RUN apt-get update && apt-get install -y \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Установка poetry
RUN pip install --no-cache-dir poetry

# Установка зависимостей с помощью poetry
COPY pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.create false && poetry install --only main

# Установка рабочей директории
WORKDIR /app

# Копирование всех файлов проекта в рабочую директорию
COPY . /app

# Команда по умолчанию
CMD ["bash"]