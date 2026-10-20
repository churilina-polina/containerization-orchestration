# 1. Базовый образ: Python 3.11 в облегчённой (slim) версии Debian
FROM python:3.11-slim

# 2. Метаданные: автор (мейнтейнер) и версия образа
LABEL maintainer="churilina@lab.local"
LABEL version="1.0"

# 3. Рабочая директория внутри контейнера
WORKDIR /app

# 4. Сначала копируем только список зависимостей
COPY requirements.txt .

# 5. Устанавливаем зависимости
RUN pip install -r requirements.txt

# 6. Копируем код приложения
COPY app/ ./app/

# 7. Порт, который слушает приложение
EXPOSE 5465

# 8. Запуск приложения на моём порту
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "5465"]
