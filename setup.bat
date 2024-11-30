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
        echo pandas^>=1.3.0,^<1.4.0
        echo scikit-learn^>=0.24.0,^<0.25.0
        echo wandb^>=0.12.0
        echo boto3^>=1.20.0
        echo joblib^>=1.0.0
        echo requests^>=2.25.0
        echo urllib3^<2
        echo numpy^>=1.19.0
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

REM Останавливаем все контейнеры
docker-compose down 2>nul
docker rm -f minio 2>nul

REM Удаляем сеть если существует
docker network rm ml_network 2>nul

REM Создаем сеть заново
docker network create ml_network

REM Очищаем образ
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