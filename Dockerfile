FROM python:3.8-slim-buster

WORKDIR /app

# Установка необходимых системных пакетов
RUN apt-get update && \
    apt-get install -y \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Копируем и устанавливаем зависимости
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Создание необходимых директорий
RUN mkdir -p output

# Копируем код
COPY . .

CMD ["python"]