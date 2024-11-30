FROM debian:buster-slim

# Установка Python и необходимых пакетов
RUN apt-get update && \
    apt-get install -y \
    python3 \
    python3-pip \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Копируем и устанавливаем зависимости
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Создание необходимых директорий
RUN mkdir -p output

# Копируем код
COPY . .

CMD ["python3"]