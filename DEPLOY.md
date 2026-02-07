# Пошаговая инструкция по деплою приложения

## Подготовка на локальной машине

### 1. Подготовка файлов
Убедитесь, что у вас есть все необходимые файлы:
- `app.py`
- `requirements.txt`
- `Dockerfile`
- `compose.prod.yml`
- `templates/` (папка с шаблонами)
- `.dockerignore`

### 2. Создание архива проекта (опционально)
```bash
# Создайте архив проекта (исключая ненужные файлы)
tar -czf reigns-app.tar.gz app.py requirements.txt Dockerfile compose.prod.yml templates/ .dockerignore
```

## Деплой на удаленном сервере

### Шаг 1: Подключение к серверу
```bash
# Подключитесь к серверу по SSH
ssh user@your-server-ip
```

### Шаг 2: Установка Docker и Docker Compose (если еще не установлены)
```bash
# Обновление пакетов
sudo apt update

# Установка Docker
sudo apt install -y docker.io docker-compose

# Добавление пользователя в группу docker (чтобы не использовать sudo)
sudo usermod -aG docker $USER
# Выйдите и войдите снова, чтобы изменения вступили в силу
```

### Шаг 3: Создание директории проекта
```bash
# Создайте директорию для проекта
mkdir -p ~/reigns-app
cd ~/reigns-app
```

### Шаг 4: Копирование файлов на сервер

**Вариант A: Через SCP (если создали архив)**
```bash
# На локальной машине:
scp reigns-app.tar.gz user@your-server-ip:~/reigns-app/

# На сервере:
cd ~/reigns-app
tar -xzf reigns-app.tar.gz
```

**Вариант B: Через Git (рекомендуется)**
```bash
# На сервере:
cd ~/reigns-app
git clone <your-repository-url> .
# или если репозиторий приватный:
git clone https://github.com/yourusername/reigns-app.git .
```

**Вариант C: Через rsync**
```bash
# На локальной машине:
rsync -avz --exclude '*.xlsx' --exclude '__pycache__' \
  ./ user@your-server-ip:~/reigns-app/
```

### Шаг 5: Настройка переменных окружения
```bash
# Создайте файл .env (опционально, для секретного ключа)
cd ~/reigns-app
nano .env
```

Добавьте в `.env`:
```
SECRET_KEY=your_very_secure_secret_key_here_change_this
```

Или установите переменную окружения напрямую:
```bash
export SECRET_KEY="your_very_secure_secret_key_here"
```

### Шаг 6: Создание директории для данных
```bash
mkdir -p ~/reigns-app/data
chmod 755 ~/reigns-app/data
```

### Шаг 7: Запуск приложения
```bash
cd ~/reigns-app

# Если используете .env файл, обновите compose.prod.yml:
# docker compose -f compose.prod.yml --env-file .env up -d

# Или просто запустите:
docker compose -f compose.prod.yml up -d --build
```

### Шаг 8: Проверка работы
```bash
# Проверьте логи
docker compose -f compose.prod.yml logs -f

# Проверьте статус контейнеров
docker compose -f compose.prod.yml ps

# Проверьте доступность приложения
curl http://localhost:5000
```

### Шаг 9: Настройка файрвола (если нужно)
```bash
# Откройте порт 5000 (если используете ufw)
sudo ufw allow 5000/tcp
sudo ufw reload

# Или для firewalld
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload
```

## Настройка Nginx как Reverse Proxy (рекомендуется)

### 1. Установка Nginx
```bash
sudo apt install -y nginx
```

### 2. Создание конфигурации
```bash
sudo nano /etc/nginx/sites-available/reigns-app
```

Добавьте конфигурацию:
```nginx
server {
    listen 80;
    server_name your-domain.com;  # или IP адрес сервера

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 3. Активация конфигурации
```bash
sudo ln -s /etc/nginx/sites-available/reigns-app /etc/nginx/sites-enabled/
sudo nginx -t  # Проверка конфигурации
sudo systemctl reload nginx
```

## Полезные команды для управления

### Остановка приложения
```bash
cd ~/reigns-app
docker compose -f compose.prod.yml down
```

### Перезапуск приложения
```bash
docker compose -f compose.prod.yml restart
```

### Просмотр логов
```bash
docker compose -f compose.prod.yml logs -f
```

### Обновление приложения
```bash
cd ~/reigns-app
# Обновите файлы (через git pull или другим способом)
git pull  # если используете git
docker compose -f compose.prod.yml up -d --build
```

### Просмотр сохраненных результатов
```bash
# Excel файл будет в папке data
ls -lh ~/reigns-app/data/
```

### Скачивание результатов с сервера
```bash
# На локальной машине:
scp user@your-server-ip:~/reigns-app/data/game_results.xlsx ./
```

## Настройка автозапуска (systemd)

Создайте сервис для автозапуска:

```bash
sudo nano /etc/systemd/system/reigns-app.service
```

Добавьте:
```ini
[Unit]
Description=REIGNS Alexander Game
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/user/reigns-app
ExecStart=/usr/bin/docker compose -f compose.prod.yml up -d
ExecStop=/usr/bin/docker compose -f compose.prod.yml down
User=user
Group=docker

[Install]
WantedBy=multi-user.target
```

Активируйте:
```bash
sudo systemctl daemon-reload
sudo systemctl enable reigns-app.service
sudo systemctl start reigns-app.service
```

## Безопасность

1. **Измените SECRET_KEY** - используйте надежный случайный ключ
2. **Настройте HTTPS** - используйте Let's Encrypt с Certbot
3. **Ограничьте доступ** - настройте файрвол
4. **Регулярные обновления** - обновляйте систему и Docker образы

## Проверка работоспособности

После деплоя проверьте:
- ✅ Приложение доступно по адресу сервера
- ✅ Можно ввести email и начать игру
- ✅ Результаты сохраняются в Excel
- ✅ Эндпоинт `/export` работает для выгрузки данных
