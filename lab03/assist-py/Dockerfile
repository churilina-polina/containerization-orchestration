# ===== Стадия 1: builder – установка зависимостей =====
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
# --no-cache-dir – без кэша pip; --prefix – ставим в отдельную папку
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ===== Стадия 2: финальный образ =====
FROM python:3.11-slim
LABEL maintainer="churilina@lab.local"
LABEL version="3.0"

# Порт приложения задаётся одной переменной и используется ниже
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8035

# curl нужен для HEALTHCHECK (в slim-образе его нет)
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /install /usr/local
COPY app/ ./app/

EXPOSE ${PORT}

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:${PORT}/health || exit 1

# Shell-форма: в ней подставляется переменная ${PORT}
CMD uvicorn app.main:app --host 0.0.0.0 --port ${PORT}
