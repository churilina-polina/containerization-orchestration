# Лабораторная работа №5. Знакомство с Kubernetes

Приложение [assist-py](https://github.com/FilBTi/assist-py) из ЛР4, PostgreSQL и Redis развёрнуты в локальном кластере minikube. Вместо Docker Compose используются Deployment, Service, ConfigMap, Secret и PersistentVolumeClaim.

## Персональные параметры

| Параметр | Значение |
|---|---|
| Номер ИСУ | 468035 |
| Префикс | `churilina` |
| Секретный ключ | `secret35churilina` |
| Имя базы данных | `churilina35` |
| Порт приложения | **8035** |
| NodePort | **30035** |

## Структура

```
lab05/
├── assist-py/
│   ├── app/                         # /, /health с проверкой БД и Redis, hostname пода
│   ├── requirements.txt
│   ├── Dockerfile
│   └── k8s/
│       ├── postgres-pvc.yaml
│       ├── postgres-deployment.yaml
│       ├── postgres-service.yaml
│       ├── redis-deployment.yaml
│       ├── redis-service.yaml
│       ├── app-configmap.yaml
│       ├── app-secret.example.yaml  # учебные значения, сам app-secret.yaml не коммитится
│       ├── app-deployment.yaml      # readinessProbe и livenessProbe
│       ├── app-service.yaml         # NodePort 30035
│       └── app-ingress.yaml         # хост churilina.local
└── screenshots/
```

## Kubernetes

| Ресурс | Имя | Назначение |
|---|---|---|
| Deployment + Service (ClusterIP) | `churilina-postgres` | PostgreSQL, данные в PVC `churilina-postgres-pvc` |
| Deployment + Service (ClusterIP) | `churilina-redis` | кэш ответов `/weather/{city}`, TTL 120 секунд |
| Deployment + Service (NodePort) | `churilina-app` | приложение, порт 8035 |
| ConfigMap | `churilina-config` | `APP_OWNER`, `PORT`, `POSTGRES_USER`, `POSTGRES_DB`, `REDIS_URL`, `CACHE_TTL` |
| Secret | `churilina-secret` | `APP_SECRET`, `POSTGRES_PASSWORD` |
| Ingress | `churilina-ingress` | `churilina.local` → `churilina-app` |

Команды выполняются из `lab05/assist-py`.

Запуск кластера и загрузка образа:

```bash
minikube start --driver=docker --cpus=2 --memory=4096
docker build -t churilina-assist:5.0 .
minikube image load churilina-assist:5.0
```

Порядок применения манифестов:

```bash
cp k8s/app-secret.example.yaml k8s/app-secret.yaml   # заполнить своими значениями
kubectl apply -f k8s/app-configmap.yaml -f k8s/app-secret.yaml
kubectl apply -f k8s/postgres-pvc.yaml -f k8s/postgres-deployment.yaml -f k8s/postgres-service.yaml
kubectl apply -f k8s/redis-deployment.yaml -f k8s/redis-service.yaml
kubectl apply -f k8s/app-deployment.yaml -f k8s/app-service.yaml
```

## Проверка

```bash
kubectl get all
kubectl logs deployment/churilina-app
kubectl describe pod -l app=churilina-app    # Ready: True, Liveness и Readiness
minikube service churilina-app --url         # адрес для запросов, терминал не закрывать
```

```bash
curl $URL/health            # "database": true, "redis": true, hostname = имя пода
curl $URL/weather/Moscow    # "source": "api"
curl $URL/weather/Moscow    # "source": "cache"
```

## Ingress

```bash
minikube addons enable ingress
kubectl apply -f k8s/app-ingress.yaml
minikube tunnel                              # в отдельном терминале
curl -H "Host: churilina.local" http://127.0.0.1/health
```
