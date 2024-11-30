@echo off
setlocal

REM Проверяем наличие Docker
where docker >nul 2>&1
if errorlevel 1 (
    echo Error: Docker is not installed
    exit /b 1
)

REM Проверяем наличие requirements.txt
if not exist requirements.txt (
    echo Creating requirements.txt...
    (
        echo pandas==1.5.3
        echo scikit-learn==1.0.2
        echo wandb==0.15.11
        echo boto3==1.28.44
        echo joblib==1.3.2
        echo requests==2.31.0
        echo urllib3^<2
        echo numpy^>=1.20.0
        echo python-dotenv^>=0.19.0
    ) > requirements.txt
)

REM Проверяем наличие .env файла
if not exist .env (
    echo Creating .env file...
    (
        echo WANDB_API_KEY=your_wandb_api_key_here
        echo MINIO_ROOT_USER=admin
        echo MINIO_ROOT_PASSWORD=Admin12345678
    ) > .env
)

REM Удаляем существующую сеть и создаем заново
docker network rm ml_network 2>nul
docker network create ml_network

REM Останавливаем существующие контейнеры
docker-compose down 2>nul
docker rm -f minio 2>nul

REM Очищаем образы
docker rmi trainer 2>nul

REM Собираем образ
echo Building Docker image...
docker build --no-cache -t trainer .

REM Запускаем MinIO
echo Starting MinIO...
docker-compose up -d minio

echo Waiting for services to start...
timeout /t 10 /nobreak

echo Setup completed successfully!
endlocal