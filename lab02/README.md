# Лабораторная работа №2. Знакомство с Docker (продолжение)

Сборка собственного образа для FastAPI-приложения [assist-py](https://github.com/FilBTi/assist-py), оптимизация (multi-stage), `.dockerignore`, `HEALTHCHECK` и теги.

## Персональные параметры

| Параметр | Значение |
|---|---|
| Номер ИСУ | 468035 |
| Персональный порт | 5430 + 35 = **5465** |
| Персональный префикс | `churilina` |
| Секретный ключ | `secret35churilina` |

## Структура

```
lab02/
├── assist-py/
│   ├── app/main.py
│   ├── requirements.txt
│   ├── Dockerfile               # базовый образ (этап 1)
│   ├── Dockerfile.optimized     # multi-stage + curl + HEALTHCHECK (этапы 2 и 4)
│   └── .dockerignore            # этап 3
└── screenshots/
```

## Воспроизведение

```bash
cd lab02/assist-py

# Этап 1 – базовый образ
docker build -t churilina-assistant:v1 .
docker run -d --name churilina-assistant-1 -p 5465:5465 \
  -e APP_OWNER=churilina -e APP_SECRET=secret35churilina churilina-assistant:v1
curl http://localhost:5465/me
curl http://localhost:5465/secret/secret35churilina
docker rm -f churilina-assistant-1

# Этап 2 – оптимизированный образ
docker build -t churilina-assistant:v2 -f Dockerfile.optimized .
docker images | grep churilina-assistant

# Этап 3 – образ с .dockerignore
docker build -t churilina-assistant:v3 .
docker run --rm churilina-assistant:v3 ls -la app

# Этап 4 – финальный образ с HEALTHCHECK
docker build -t churilina-assistant:final -f Dockerfile.optimized .
docker run -d --name churilina-assistant-final -p 5465:5465 \
  -e APP_OWNER=churilina -e APP_SECRET=secret35churilina churilina-assistant:final
sleep 10
docker ps --filter "name=churilina-assistant-final" --format "table {{.Names}}\t{{.Status}}"

# Этап 5 – теги
docker tag churilina-assistant:final churilina-assistant:1.0.0
docker tag churilina-assistant:final churilina-assistant:$(date +%Y%m%d)
docker images churilina-assistant --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Очистка
docker rm -f churilina-assistant-final
```

## Результаты

| Образ | Размер | Что внутри |
|---|---|---|
| `v1` | 310 MB | базовый Dockerfile |
| `v2` | 267 MB | `--no-cache-dir` + multi-stage (−43 MB) |
| `v3` | 310 MB | базовый Dockerfile + `.dockerignore` |
| `final` = `1.0.0` = `20261020` | 287 MB | v2 + curl + `HEALTHCHECK`, статус `(healthy)` |

## Замечания к заданию

- В `python:3.11-slim` нет `curl`, поэтому для `HEALTHCHECK` он устанавливается в `Dockerfile.optimized`.
- Шаблоны `__pycache__/` и `*.pyc` в `.dockerignore` действуют только в корне контекста; для `app/__pycache__` добавлены `**/__pycache__` и `**/*.pyc`.
- В Docker 29 изменился формат `docker images`, поэтому `awk '{print $1, $2, $7}'` не выводит размеры – в артефакте использован `--format`.
