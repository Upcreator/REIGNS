# Быстрый деплой - краткая инструкция

## На удаленном сервере выполните:

```bash
# 1. Создайте директорию
mkdir -p ~/reigns-app && cd ~/reigns-app

# 2. Скопируйте файлы проекта (через git/scp/rsync)

# 3. Создайте папку для данных
mkdir -p data

# 4. Установите секретный ключ (важно!)
export SECRET_KEY="ваш_случайный_секретный_ключ_здесь"

# 5. Запустите приложение
docker compose -f compose.prod.yml up -d --build

# 6. Проверьте логи
docker compose -f compose.prod.yml logs -f
```

## Проверка работы:
- Откройте в браузере: `http://your-server-ip:5000`
- Или настройте Nginx для домена (см. DEPLOY.md)

## Полезные команды:
```bash
# Остановка
docker compose -f compose.prod.yml down

# Перезапуск
docker compose -f compose.prod.yml restart

# Логи
docker compose -f compose.prod.yml logs -f

# Обновление
git pull && docker compose -f compose.prod.yml up -d --build
```

Подробная инструкция в файле `DEPLOY.md`
