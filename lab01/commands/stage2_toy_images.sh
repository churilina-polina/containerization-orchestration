#!/bin/sh
# Этап 2. Первые шаги: «игрушечные» образы

# 2.1 Классический пример
docker run --rm hello-world

# 2.2 Минимальный образ Alpine
docker run --rm alpine:3.18 cat /etc/os-release
docker images alpine:3.18 --format "{{.Size}}"

# 2.3 Два фоновых контейнера
docker run -d --name churilina-alpine-1 alpine:3.18 sleep 300
docker run -d --name churilina-alpine-2 alpine:3.18 sh -c "echo 'Hello from $(hostname)' && sleep 300"
docker ps --filter "name=churilina-alpine"
docker logs churilina-alpine-2
