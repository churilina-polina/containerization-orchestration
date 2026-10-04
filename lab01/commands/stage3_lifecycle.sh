#!/bin/sh
# Этап 3. Жизненный цикл контейнера
# После каждого действия выводится статус контейнера (задание 3.2)

STATUS='docker ps -a --filter "name=churilina-nginx" --format "table {{.Names}}\t{{.Status}}\t{{.CreatedAt}}"'

docker create --name churilina-nginx nginx:alpine && eval "$STATUS"   # Created
docker start churilina-nginx && eval "$STATUS"                        # Up
docker stop churilina-nginx && eval "$STATUS"                         # Exited (0), SIGTERM
docker restart churilina-nginx && eval "$STATUS"                      # Up
docker kill churilina-nginx && eval "$STATUS"                         # Exited (137), SIGKILL
docker rm churilina-nginx && eval "$STATUS"                           # удалён

# Удаление запущенного контейнера
docker run -d --name churilina-nginx-test nginx:alpine
docker rm churilina-nginx-test       # ошибка: container is running
docker rm -f churilina-nginx-test    # принудительное удаление
