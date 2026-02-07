# Dockerfile
FROM python:3.9-slim

WORKDIR /app

# Увеличиваем таймауты для pip и устанавливаем зависимости
COPY requirements.txt .
RUN pip install --no-cache-dir --default-timeout=100 --retries=5 -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]