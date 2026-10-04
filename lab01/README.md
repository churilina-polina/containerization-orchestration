# Практическая работа №1. Знакомство с экосистемой Docker

Дисциплина «Контейнеризация и оркестрация приложений», ИТМО, осень 2026.

**Студент:** Чурилина Полина

## Персональные параметры

| Параметр | Значение |
|---|---|
| Номер ИСУ | 468035 |
| Персональный порт | 5430 + 35 = **5465** |
| Персональный префикс | `churilina` |

## Окружение

- macOS (Apple Silicon, arm64), Docker Desktop
- Docker Engine 29.7.2 (client и server), `linux/aarch64`

## Структура репозитория

```
commands/
  stage1_environment.sh   # Этап 1 — версии, docker system df, артефакт окружения
  stage2_toy_images.sh    # Этап 2 — hello-world, alpine, фоновые контейнеры
  stage3_lifecycle.sh     # Этап 3 — create/start/stop/restart/kill/rm nginx
  stage4_postgres.sh      # Этап 4 — postgres без пароля → диагностика → исправление
  cleanup.sh              # удаление всех контейнеров работы
screenshots/              # скриншоты терминала по этапам
```

## Воспроизведение

Требуется установленный и запущенный Docker (Docker Desktop или dockerd).

```bash
git clone https://github.com/churilina-polina/containerization-orchestration.git
cd containerization-orchestration/lab01
docker version          # проверка, что демон доступен

sh commands/stage1_environment.sh
sh commands/stage2_toy_images.sh
sh commands/stage3_lifecycle.sh
sh commands/stage4_postgres.sh
```

Проверка, что PostgreSQL работает и доступен на персональном порту:

```bash
docker exec churilina-pg-fixed psql -U user_468035 -c "SELECT version();"
docker ps --filter "name=churilina-pg-fixed" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

Очистка после работы:

```bash
sh commands/cleanup.sh
```

## Результаты

| Этап | Результат |
|---|---|
| 1 | Client/Server 29.7.2, `linux/aarch64`; до начала работы 26 образов, 17 активных контейнеров |
| 2 | `hello-world` из `docker.io/library/hello-world:latest` (arm64v8), выполняется `/hello`; `PRETTY_NAME="Alpine Linux v3.18"`, размер образа 11.8MB |
| 3 | Created → Up → Exited (0) [SIGTERM] → Up → **Exited (137)** [SIGKILL] → удалён |
| 4 | Без `POSTGRES_PASSWORD` контейнер падает с кодом 1; с паролем — `Up`, порт `0.0.0.0:5465->5432/tcp`, PostgreSQL 15.19 |

## Замечание

В задании 1.3 используется поле `{{.Server.Architecture}}`, которого нет в выводе
`docker version` (Docker 29): команда завершается ошибкой
`can't evaluate field Architecture`. Корректное поле — `{{.Server.Arch}}`.
