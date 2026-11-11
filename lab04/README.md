# Лабораторная работа №4. Docker Compose

Приложение [assist-py](https://github.com/FilBTi/assist-py), PostgreSQL и Redis запускаются одной командой. Погода кэшируется в Redis, сервис приложения масштабируется.

## Персональные параметры

| Параметр | Значение |
|---|---|
| Номер ИСУ | 468035 |
| Порт PostgreSQL | 5430 + 35 = **5465** |
| Порт Redis | 6370 + 35 = **6405** |
| Порт приложения | 8000 + 35 = **8035** |
| Префикс | `churilina` |
| Секретный ключ | `secret35churilina` |
| Имя базы данных | `churilina35` |

## Структура

```
lab04/
├── assist-py/
│   ├── app/                      # FastAPI + PostgreSQL + кэш Redis
│   ├── config/app.conf
│   ├── requirements.txt
│   ├── Dockerfile
│   ├── docker-compose.yml        # app, db, redis
│   ├── docker-compose.scale.yml  # конфигурация для масштабирования
│   └── .env.example              # шаблон переменных, сам .env не коммитится
└── screenshots/
```

## Docker Compose

| Сервис | Контейнер | Порт на хосте | Назначение |
|---|---|---|---|
| `app` | `churilina-assistant` | 8035 | приложение, запускается после healthy `db` и `redis` |
| `db` | `churilina-postgres` | 5465 | PostgreSQL, данные в томе `churilina-pgdata` |
| `redis` | `churilina-redis` | 6405 | кэш ответов `/weather/{city}`, TTL 120 секунд |

Все сервисы подключены к сети `churilina-backend`. Команды выполняются из `lab04/assist-py`.

```bash
cp .env.example .env              # заполнить своими значениями
docker compose up -d --build
docker compose ps
```

## Проверка кэша

```bash
curl http://localhost:8035/weather/Moscow    # "source": "api"
curl http://localhost:8035/weather/Moscow    # "source": "cache"
curl http://localhost:8035/cache/stats
docker exec churilina-redis redis-cli KEYS "weather:*"
```

## Масштабирование

У масштабируемого сервиса нет `container_name` и фиксированного порта на хосте: Docker назначает порт каждому экземпляру сам.

```bash
docker compose down
docker compose -f docker-compose.scale.yml up -d --build --scale app=3
docker compose -f docker-compose.scale.yml ps
docker compose -f docker-compose.scale.yml down
```

Все экземпляры используют один Redis, поэтому ответ, закэшированный одним экземпляром, получает и другой.
