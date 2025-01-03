@echo off
setlocal enabledelayedexpansion

REM Загружаем переменные из .env
for /f "tokens=1,* delims==" %%a in (.env) do (
    set "%%a=%%b"
)

set CONFIG_PATH=%~1
set EXPERIMENT_NAME=%~2

if "%CONFIG_PATH%"=="" (
    echo Usage: %0 ^<config_path^> ^<experiment_name^>
    exit /b 1
)
if "%EXPERIMENT_NAME%"=="" (
    echo Usage: %0 ^<config_path^> ^<experiment_name^>
    exit /b 1
)

REM Проверяем WANDB_API_KEY
if "%WANDB_API_KEY%"=="" (
    echo Error: WANDB_API_KEY not set in .env file
    exit /b 1
)

echo Generating parameter combinations...
echo import json > temp_script.py
echo import itertools >> temp_script.py
echo with open('%CONFIG_PATH%') as f: >> temp_script.py
echo     config = json.load(f) >> temp_script.py
echo     param_combinations = list(itertools.product(*config.values())) >> temp_script.py
echo     for params in param_combinations: >> temp_script.py
echo         print('%EXPERIMENT_NAME%_' + '_'.join(map(str, params))) >> temp_script.py

python temp_script.py > temp_combinations.txt

for /f "tokens=*" %%a in (temp_combinations.txt) do (
    echo Running experiment: %%a

    docker run --rm ^
        --network ml_network ^
        --env WANDB_API_KEY=%WANDB_API_KEY% ^
        --env MINIO_ROOT_USER=%MINIO_ROOT_USER% ^
        --env MINIO_ROOT_PASSWORD=%MINIO_ROOT_PASSWORD% ^
        --env MINIO_ENDPOINT=http://minio:9000 ^
        -v "%CD%\lab3:/app/lab3" ^
        -v "%CD%\output:/app/output" ^
        trainer ^
        python lab3/scripts/train_model.py ^
        --config "/app/%CONFIG_PATH%" ^
        --dataset "/app/lab3/titanic_processed.csv" ^
        --experiment "%%a"

    if errorlevel 1 (
        echo Error: Experiment %%a failed
    ) else (
        echo Experiment %%a completed successfully
    )
)

del temp_script.py
del temp_combinations.txt

echo All experiments completed
endlocal