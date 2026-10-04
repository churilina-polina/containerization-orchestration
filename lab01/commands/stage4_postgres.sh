#!/bin/sh
# Этап 4. Диагностика реального сервиса
# Персональный порт: 5430 + 35 = 5465, ИСУ: 468035

# 4.1 Запуск с ошибкой (нет POSTGRES_PASSWORD)
docker run -d --name churilina-pg-broken -p 5465:5432 postgres:15
sleep 5
docker ps -a --filter "name=churilina-pg"
docker logs --timestamps churilina-pg-broken 2>&1 | tail -20
docker inspect churilina-pg-broken --format='{{.State.ExitCode}}'

# 4.2 Исправление
docker run -d \
  --name churilina-pg-fixed \
  -e POSTGRES_PASSWORD=Pass_5465 \
  -e POSTGRES_USER=user_468035 \
  -p 5465:5432 \
  postgres:15
sleep 15
docker exec churilina-pg-fixed psql -U user_468035 -c "SELECT version();"
docker ps -a --filter "name=churilina-pg" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# 4.3 Финальный артефакт
echo "=== Практика №1: $(date '+%Y-%m-%d %H:%M:%S') ===" && \
echo "Студент: $(whoami)@$(hostname)" && \
docker ps --filter "name=churilina-pg-fixed" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
