[🏠 Главная](../../README.md) → [🐳 Virtualization-and-Containerization](../../README.md#-virtualization-and-containerization) → [📝 V-03-Dockerfile](../../README.md#-v-03-dockerfile)

---

# 🐳V-03-2-Dockerfile-Практика
> Продвинутые техники работы с Dockerfile: оптимизация, безопасность, лучшие практики для production.

---

<details>
<summary><b>🎯 Оптимизация размера образа</b></summary>

---

### Выбор базового образа

```dockerfile
# Плохо: большой образ
FROM ubuntu:20.04
RUN apt update && apt install -y python3

# Хорошо: минимальный образ
FROM python:3.9-slim

# Отлично: alpine-based
FROM python:3.9-alpine

# Best practice: использовать официальные slim/alpine образы
```

### Очистка кэша пакетных менеджеров

```dockerfile
# Для apt (Debian/Ubuntu)
RUN apt update && \
    apt install -y --no-install-recommends python3 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Для apk (Alpine)
RUN apk add --no-cache python3

# Для yum (CentOS/RHEL)
RUN yum install -y python3 && \
    yum clean all && \
    rm -rf /var/cache/yum
```

### Многостадийные сборки

```dockerfile
# Build stage с полным набором инструментов
FROM node:16 as builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage - только необходимые файлы
FROM node:16-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
CMD ["node", "dist/server.js"]
```

---

</details>

<details>
<summary><b>🔒 Безопасность в Dockerfile</b></summary>

---

### Непривилегированные пользователи

```dockerfile
# Создание непривилегированного пользователя
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Установка прав на файлы
COPY --chown=appuser:appuser . /app

# Смена пользователя
USER appuser

WORKDIR /app
CMD ["node", "server.js"]
```

### Защита чувствительных данных

```dockerfile
# Плохо: секреты в Dockerfile
ENV DB_PASSWORD="secret123"

# Хорошо: передача через build-args (но все равно видно в истории)
ARG DB_PASSWORD
RUN echo "DB password is set"

# Лучше: передача во время запуска контейнера
# docker run -e DB_PASSWORD=secret my-app
```

### Удаление временных файлов

```dockerfile
# Удаление временных файлов в том же RUN
RUN apt update && \
    apt install -y build-essential && \
    # ... сборка приложения ...
    apt remove -y build-essential && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
```

---

</details>

<details>
<summary><b>⚡ Оптимизация кэширования</b></summary>

---

### Стратегия копирования файлов

```dockerfile
# Плохо: кэширование ломается при любом изменении
COPY . /app
RUN npm install
RUN npm run build

# Хорошо: зависимости кэшируются отдельно
COPY package.json package-lock.json ./
RUN npm install

COPY . .
RUN npm run build

# Отлично: для monorepo
COPY package.json package-lock.json ./
COPY packages/core/package.json ./packages/core/
COPY packages/web/package.json ./packages/web/
RUN npm install
```

### Использование .dockerignore

```text
# .dockerignore - критически важен для скорости сборки
.git
.gitignore
README.md
node_modules
**/node_modules
*.log
.env
Dockerfile
.dockerignore
dist
coverage
.nyc_output
.docker
```

### Управление слоями

```dockerfile
# Объединение связанных команд
RUN apt update && \
    apt install -y git curl wget && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Логическая группировка операций
RUN groupadd -r app && \
    useradd -r -g app app && \
    mkdir -p /app && \
    chown -R app:app /app
```

---

</details>

<details>
<summary><b>🚀 Продвинутые техники</b></summary>

---

### Health checks

```dockerfile
# Простая проверка здоровья
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Для приложений без curl
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD ["python", "healthcheck.py"]
```

### Multi-arch сборки

```dockerfile
# Поддержка разных архитектур
FROM --platform=$BUILDPLATFORM node:16 as builder
WORKDIR /app
COPY . .
RUN npm run build

FROM node:16-alpine
COPY --from=builder /app/dist /app
CMD ["node", "/app/server.js"]
```

### Динамическая конфигурация

```dockerfile
# Использование скриптов для настройки
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["node", "server.js"]
```

```bash
#!/bin/bash
# docker-entrypoint.sh
set -e

# Настройка на основе переменных окружения
if [ "$NODE_ENV" = "production" ]; then
    export APP_PORT=80
fi

exec "$@"
```

---

</details>

<details>
<summary><b>🔧 Профили сборки</b></summary>

---

### Разные Dockerfile для разных окружений

```dockerfile
# Dockerfile.dev - для разработки
FROM node:16
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
CMD ["npm", "run", "dev"]
```

```dockerfile
# Dockerfile.prod - для продакшн
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
USER node
CMD ["node", "server.js"]
```

### Использование целевых стадий (target stages)

```dockerfile
# Development stage
FROM node:16 as development
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
CMD ["npm", "run", "dev"]

# Production stage  
FROM node:16-alpine as production
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
USER node
CMD ["node", "server.js"]
```

```bash
# Сборка конкретной стадии
docker build --target development -t my-app:dev .
docker build --target production -t my-app:prod .
```

---

</details>

<details>
<summary><b>📊 Анализ и отладка</b></summary>

---

### Анализ размера образов

```bash
# Просмотр размера образов
docker images

# Детальный анализ слоев
docker history my-image:latest

# Анализ с dive (требуется установка)
dive my-image:latest

# Экспорт метаданных
docker image inspect my-image:latest > image-info.json
```

### Отладка сборки

```bash
# Сборка с выводом всех шагов
docker build --progress=plain .

# Пропуск кэша
docker build --no-cache .

# Сохранение промежуточных образов
docker build --target builder -t my-app:builder .

# Сборка с детальными логами
docker build --build-arg BUILDKIT_INLINE_CACHE=1 .
```

### Тестирование сборки

```bash
# Тестирование multi-stage сборки
docker build --target builder -t my-app:builder .
docker build --target production -t my-app:prod .

# Проверка работоспособности
docker run -d --name test-app my-app:prod
docker logs test-app
docker exec test-app curl -f http://localhost:3000/health

# Очистка тестового контейнера
docker rm -f test-app
```

---

</details>

<details>
<summary><b>🏗️ Production-ready примеры</b></summary>

---

### Production Python приложение

```dockerfile
FROM python:3.9-slim as builder

RUN apt update && \
    apt install -y --no-install-recommends gcc python3-dev && \
    pip install --user --no-cache-dir poetry

WORKDIR /app
COPY pyproject.toml poetry.lock ./
RUN python -m poetry export -f requirements.txt --output requirements.txt

FROM python:3.9-slim

RUN groupadd -r app && useradd -r -g app app

WORKDIR /app

COPY --from=builder /app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=app:app . .

USER app

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
    CMD python -c "import requests; requests.get('http://localhost:8000/health')"

CMD ["gunicorn", "app:app", "-b", "0.0.0.0:8000"]
```

### Production Node.js приложение

```dockerfile
FROM node:16-alpine as builder

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --include=dev
COPY . .
RUN npm run build

FROM node:16-alpine

RUN addgroup -g 1001 -S app && \
    adduser -S app -u 1001

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --only=production && \
    npm cache clean --force

COPY --from=builder --chown=app:app /app/dist ./dist
COPY --chown=app:app . .

USER app

EXPOSE 3000

ENV NODE_ENV=production

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
    CMD node healthcheck.js

CMD ["node", "dist/server.js"]
```

---

</details>

<details>
<summary><b>🎯 Ключевые выводы</b></summary>

---

### Best Practices Checklist

```text
✅ Используйте многостадийные сборки
✅ Создавайте непривилегированных пользователей
✅ Очищайте кэш пакетных менеджеров
✅ Используйте .dockerignore
✅ Объединяйте RUN команды
✅ Добавляйте HEALTHCHECK
✅ Используйте конкретные версии тегов
✅ Минимизируйте количество слоев
✅ Тестируйте сборки в CI/CD
```

### Производительность

```text
🚀 Slim/alpine образы уменьшают размер на 50-80%
⚡ Многостадийные сборки исключают build-зависимости
📦 Правильное кэширование ускоряет сборку в 10+ раз
🔧 .dockerignore предотвращает копирование ненужных файлов
```

### Что дальше

```text
📚 Следующая тема: Docker Volumes - работа с постоянными данными
🔜 Затем: Docker Networking - сетевое взаимодействие
🎯 Цель: Создавать безопасные и оптимизированные production-образы
```

---

</details>
