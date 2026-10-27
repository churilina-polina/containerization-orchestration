# Лабораторная работа №3. Персистентность и изоляция

PostgreSQL для приложения [assist-py](https://github.com/FilBTi/assist-py) (ветка `lab-2` – версия с БД), именованный volume, bind mount конфигурации и пользовательская сеть.

## Персональные параметры

| Параметр | Значение |
|---|---|
| Номер ИСУ | 468035 |
| Порт PostgreSQL | 5430 + 35 = **5465** |
| Порт приложения | 8000 + 35 = **8035** |
| Префикс | `churilina` |
| Секретный ключ | `secret35churilina` |
| Имя базы данных | `churilina35` |

## Структура

```
lab03/
├── assist-py/
│   ├── app/                 # FastAPI + SQLAlchemy (PostgreSQL)
│   ├── config/app.conf      # конфигурация для bind mount, без паролей
│   ├── requirements.txt
│   ├── Dockerfile           # multi-stage, PORT=8035, HEALTHCHECK
│   └── .dockerignore
└── screenshots/
```

## Хранение данных

| Объект | Имя | Назначение |
|---|---|---|
| Именованный volume | `churilina-pgdata` | файлы PostgreSQL (`/var/lib/postgresql/data`), переживают удаление контейнеров |
| Bind mount | `./config` → `/app/config` (`:ro`) | конфигурация приложения, только чтение, меняется без пересборки |
| Пользовательская сеть | `churilina-backend` | связь приложения и БД по имени контейнера; БД не публикуется на хосте |

Все команды выполняются из `lab03/assist-py`.

```bash
# Образ приложения
docker build -t churilina-assistant:v3 .

# Volume и сеть
docker volume create churilina-pgdata
docker network create churilina-backend

# PostgreSQL – данные в volume, порт наружу не публикуется
docker run -d \
  --name churilina-postgres \
  --network churilina-backend \
  -e POSTGRES_USER=user_35 \
  -e POSTGRES_PASSWORD=pgpass_35 \
  -e POSTGRES_DB=churilina35 \
  -v churilina-pgdata:/var/lib/postgresql/data \
  postgres:15

sleep 5   # приложение при старте сразу создаёт таблицы в БД

# Приложение – БД по имени контейнера, конфиг через bind mount
docker run -d \
  --name churilina-assistant \
  --network churilina-backend \
  -p 8035:8035 \
  -e APP_OWNER=churilina \
  -e APP_SECRET=secret35churilina \
  -e DATABASE_URL="postgresql://user_35:pgpass_35@churilina-postgres:5432/churilina35" \
  -v "$(pwd)/config:/app/config:ro" \
  churilina-assistant:v3
```

Кавычки вокруг `-v "$(pwd)/…"` обязательны, если в пути есть пробелы.

## Проверка

```bash
curl http://localhost:8035/health
curl -X POST http://localhost:8035/notes -H "Content-Type: application/json" -d '{"text": "ЛР3: сеть работает!"}'
curl -s http://localhost:8035/notes | python3 -m json.tool --no-ensure-ascii

# Персистентность: заметки остаются после пересоздания контейнеров
docker rm -f churilina-assistant churilina-postgres   # затем снова команды запуска выше

# Изоляция: вне сети имя не разрешается, внутри – да
docker run --rm alpine:3.18 ping -c 2 churilina-postgres
docker run --rm --network churilina-backend alpine:3.18 ping -c 2 churilina-postgres
```

## Очистка

```bash
docker rm -f churilina-assistant churilina-postgres
docker network rm churilina-backend
docker volume rm churilina-pgdata   # удалит и данные БД
```

## Замечания

- `/health` в этой версии приложения не обращается к БД; подключение подтверждается сохранением и чтением заметок.
- `CMD` в shell-форме (нужно для `${PORT}`) делает PID 1 оболочкой `/bin/sh`, и `docker stop` ждёт 10 с. Исправление: `CMD exec uvicorn …`.
- `python3 -m json.tool` без `--no-ensure-ascii` выводит кириллицу кодами `\uXXXX`.
