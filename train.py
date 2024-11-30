import mlflow
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
import pandas as pd

def train_model(data_path: str, hyperparameters: dict) -> None:
    # Загрузка данных
    df = pd.read_csv(data_path)
    X = df.drop('target', axis=1)
    y = df['target']

    # Разделение данных
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

    # Обучение модели
    model = RandomForestClassifier(**hyperparameters)
    model.fit(X_train, y_train)

    # Оценка модели
    predictions = model.predict(X_test)
    accuracy = accuracy_score(y_test, predictions)

    # Логирование метрик
    mlflow.log_params(hyperparameters)
    mlflow.log_metric("accuracy", accuracy)

    # Сохранение модели
    mlflow.sklearn.log_model(model, "model")