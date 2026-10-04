#!/bin/sh
# Этап 1. Верификация окружения и архитектуры

# 1.1 Версии клиента и сервера, ОС/архитектура демона
docker version --format "Client: {{.Client.Version}}, Server: {{.Server.Version}}"
docker info --format "{{.OSType}}/{{.Architecture}}"

# 1.2 Использование диска ресурсами Docker
docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Active}}\t{{.Size}}"

# 1.3 Артефакт окружения
# В задании указано {{.Server.Architecture}}, но в Docker 29 такого поля нет,
# корректное имя поля — {{.Server.Arch}}
echo "Student: $(whoami)@$(hostname)" && \
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')" && \
docker version --format "Docker {{.Server.Version}} on {{.Server.Os}}/{{.Server.Arch}}"
