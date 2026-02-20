# Docker Login Project

## Быстрый старт

```bash
cd docker-login-project

# Запустить бэкенд + БД
docker compose up --build

# Проверить
curl http://localhost:8000/health
```

## Swagger UI
http://localhost:8000/docs

## Тестирование через curl

```bash
# Регистрация
curl -X POST http://localhost:8000/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@mail.com","username":"kopa","password":"12345"}'

# Вход
curl -X POST http://localhost:8000/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@mail.com","password":"12345"}'

# Профиль
curl http://localhost:8000/profile \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Docker команды

```bash
docker compose up --build    # собрать и запустить
docker compose up -d         # в фоне
docker compose down          # остановить
docker compose down -v       # остановить + удалить данные БД
docker compose logs backend  # логи
docker ps                    # список контейнеров
```

## SwiftUI
См. `ios-app/SETUP_XCODE.md`
