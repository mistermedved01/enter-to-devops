[🏠 Главная](../../README.md) → [🐳 Virtualization-and-Containerization](../../README.md#-virtualization-and-containerization) → [🏭 V-06-Production](../../README.md#-v-06-production)

---

# 🐳V-06-5-Best-Practices
> Итоговый гайд по лучшим практикам Docker: безопасность, производительность, организация проектов и production-готовность.

---

<details>
<summary><b>🎯 Общие принципы</b></summary>

---

### Philosophy Docker Best Practices

```text
# Основные принципы работы с Docker:

🔹 **Контейнеры эфемерны**
• Контейнеры должны быть легко заменяемыми
• Данные хранить в томах, не в контейнерах
• Быстрый запуск и остановка

🔹 **Идемпотентность**
• Повторные сборки дают одинаковый результат
• Не зависит от времени сборки
• Воспроизводимость на разных системах

🔹 **Минимализм**
• Использовать минимальные базовые образы
• Удалять ненужные файлы в процессе сборки
• Оставлять только необходимое для работы приложения
```

### 12-Factor App в Docker

```text
✅ **Codebase** - один код в системе контроля версий
✅ **Dependencies** - явное объявление зависимостей
✅ **Config** - конфигурация через переменные окружения
✅ **Backing services** - БД, кэш как attached resources
✅ **Build, release, run** - разделение стадий
✅ **Processes** - stateless процессы
✅ **Port binding** - экспорт портов
✅ **Concurrency** - масштабирование через процессы
✅ **Disposability** - быстрый запуск и graceful shutdown
✅ **Dev/prod parity** - одинаковые окружения
✅ **Logs** - логи как поток событий
✅ **Admin processes** - админ задачи как разовые процессы
```

---

</details>

<details>
<summary><b>📝 Dockerfile Best Practices</b></summary>

---

### Выбор базового образа

```dockerfile
# ПЛОХО - большой образ
FROM ubuntu:latest
RUN apt update && apt install -y nodejs npm

# ХОРОШО - официальный образ
FROM node:18

# ОТЛИЧНО - минимальный образ
FROM node:18-alpine

# ЛУЧШЕ - distroless для production
FROM gcr.io/distroless/nodejs:18
```

### Оптимизация слоев

```dockerfile
# ПЛОХО - много слоев
RUN apt update
RUN apt install -y python3
RUN apt install -y python3-pip
RUN pip install flask
RUN apt clean

# ХОРОШО - объединенные команды
RUN apt update && \
    apt install -y python3 python3-pip && \
    pip install flask && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
```

### Кэширование зависимостей

```dockerfile
# ПЛОХО - зависимости копируются после кода
COPY . /app
RUN npm install

# ХОРОШО - зависимости кэшируются отдельно
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run build
```

### Безопасность

```dockerfile
# Создание непривилегированного пользователя
RUN groupadd -r app && useradd -r -g app app

# Копирование файлов с правильными правами
COPY --chown=app:app . /app

# Смена пользователя
USER app

# Read-only корневая ФС
docker run --read-only -v /tmp:/tmp my-app
```

---

</details>
<details>
<summary><b>🔒 Безопасность</b></summary>

---

### Security Hardening

```bash
# Запуск без привилегий
docker run -d --security-opt=no-new-privileges nginx

# Отключение всех capabilities
docker run -d --cap-drop=ALL --cap-add=NET_BIND_SERVICE nginx

# Read-only файловая система
docker run -d --read-only --tmpfs /tmp nginx

# AppArmor/SELinux
docker run -d --security-opt apparmor=docker-default nginx
```

### Сканирование образов

```bash
# Регулярное сканирование на уязвимости
docker scout cves my-app:latest

# Сканирование с Trivy
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image my-app:latest

# Проверка на соответствие best practices
docker scout recommendations my-app:latest
```

### Безопасная конфигурация

```json
{
  "userns-remap": "default",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "live-restore": true,
  "userland-proxy": false,
  "no-new-privileges": true
}
```

---

</details>

<details>
<summary><b>🚀 Производительность</b></summary>

---

### Оптимизация размера образов

```dockerfile
# Многостадийные сборки
FROM node:18 as builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

### .dockerignore файл

```text
# .dockerignore
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

### Управление ресурсами

```bash
# Ограничение ресурсов
docker run -d \
  --memory=512m \
  --cpus=1.0 \
  --blkio-weight=500 \
  nginx:alpine

# Production ограничения
docker run -d \
  --memory=1g \
  --memory-reservation=512m \
  --cpus=2.0 \
  --cpu-shares=512 \
  my-app:prod
```

---

</details>

<details>
<summary><b>🏗️ Организация проектов</b></summary>

---

### Структура проекта

```text
my-project/
├── docker-compose.yml
├── docker-compose.prod.yml
├── .env.example
├── .dockerignore
├── backend/
│   ├── Dockerfile
│   ├── Dockerfile.dev
│   ├── src/
│   └── package.json
├── frontend/
│   ├── Dockerfile
│   ├── Dockerfile.dev
│   └── src/
├── nginx/
│   ├── nginx.conf
│   └── Dockerfile
└── scripts/
    ├── deploy.sh
    └── backup.sh
```

### Docker Compose организация

```yaml
# Базовый docker-compose.yml
version: '3.8'

services:
  backend:
    build: ./backend
    environment:
      - NODE_ENV=development
    volumes:
      - ./backend:/app
    ports:
      - "3000:3000"

  database:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:
```

```yaml
# docker-compose.override.yml (development)
version: '3.8'

services:
  backend:
    command: npm run dev
    environment:
      - DEBUG=true

  frontend:
    build: ./frontend
    ports:
      - "3001:3000"
```

### Environment management

```bash
# .env файл
DB_PASSWORD=secure_password
REDIS_URL=redis://redis:6379
API_KEY=your_api_key_here

# Использование в compose
docker-compose --env-file .env.production up -d
```

---

</details>

<details>
<summary><b>📦 Image Management</b></summary>

---

### Тегирование версий

```bash
# Семантическое версионирование
docker build -t my-app:1.2.3 .
docker build -t my-app:latest .

# Теги для разных окружений
docker build -t my-app:staging .
docker build -t my-app:production .

# Теги с хэшем коммита
docker build -t my-app:$(git rev-parse --short HEAD) .
```

### Registry best practices

```bash
# Использование конкретных версий
FROM nginx:1.23-alpine

# Подпись образов
docker trust sign my-app:1.2.3

# Сканирование перед использованием
docker scout cves nginx:1.23-alpine
```

### Очистка образов

```bash
# Регулярная очистка
docker image prune -a

# Удаление по фильтру
docker images --filter "dangling=true" -q | xargs docker rmi

# Очистка системы
docker system prune -a --volumes
```

---

</details>

<details>
<summary><b>🔧 Development Workflow</b></summary>

---

### Локальная разработка

```yaml
# docker-compose.dev.yml
version: '3.8'

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    volumes:
      - ./backend:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - DEBUG=true
    command: npm run dev

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    volumes:
      - ./frontend:/app
      - /app/node_modules
    command: npm run dev
```

### Hot-reload настройка

```dockerfile
# Dockerfile.dev
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
```

### Отладка

```bash
# Просмотр логов
docker-compose logs -f backend

# Debug контейнер
docker run -it --rm my-app:debug bash

# Инспект контейнера
docker inspect my-container

# Статистика ресурсов
docker stats
```

---

</details>

<details>
<summary><b>🏭 Production Ready</b></summary>

---

### Health checks

```yaml
services:
  backend:
    image: my-app:latest
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

### Мониторинг и логи

```yaml
services:
  backend:
    image: my-app:latest
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1.0'
```

### High Availability

```yaml
# Docker Swarm конфигурация
deploy:
  replicas: 3
  update_config:
    parallelism: 2
    delay: 10s
    failure_action: rollback
  restart_policy:
    condition: on-failure
    delay: 5s
    max_attempts: 3
  resources:
    limits:
      memory: 512M
```

---

</details>

<details>
<summary><b>🚀 CI/CD Integration</b></summary>

---

### GitHub Actions пример

```yaml
# .github/workflows/docker.yml
name: Build and Push Docker Image

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Docker image
      run: docker build -t my-app:${{ github.sha }} .
    
    - name: Scan for vulnerabilities
      run: docker scout cves my-app:${{ github.sha }}
    
    - name: Push to Registry
      run: |
        echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
        docker push my-app:${{ github.sha }}
```

### Multi-stage в CI/CD

```dockerfile
# Multi-stage для разных этапов
FROM node:18 as test
WORKDIR /app
COPY . .
RUN npm install
RUN npm test

FROM node:18 as build
WORKDIR /app
COPY --from=test /app .
RUN npm run build

FROM nginx:alpine as production
COPY --from=build /app/dist /usr/share/nginx/html
```

---

</details>

<details>
<summary><b>🔍 Troubleshooting</b></summary>

---

### Диагностика проблем

```bash
# Проверка состояния системы
docker system df
docker system events
docker stats

# Анализ образов
docker image history my-image
docker scout recommendations my-image

# Сетевые проблемы
docker network ls
docker network inspect my-network
```

### Отладка контейнеров

```bash
# Логи в реальном времени
docker logs -f --tail=100 my-container

# Интерактивная отладка
docker exec -it my-container bash

# Проверка конфигурации
docker inspect my-container

# Health status
docker ps --format "table {{.Names}}\t{{.Status}}"
```

### Производительность

```bash
# Профилирование
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Анализ слоев
docker history my-image

# Размер образов
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

---

</details>

<details>
<summary><b>📚 Learning Path</b></summary>

---

### Рекомендуемые ресурсы

```text
📖 Документация:
• Official Docker Documentation
• Dockerfile Reference
• Docker Compose Specification

🎓 Курсы и обучение:
• Docker Certified Associate (DCA)
• Kubernetes courses
• Cloud provider certifications

🛠️ Инструменты:
• Portainer - GUI управление
• Dive - анализ образов
• Trivy - security scanning
• cTop - мониторинг контейнеров
```

### Практические проекты

```text
🚀 Для закрепления навыков:
1. Микросервисное приложение
2. CI/CD пайплайн с Docker
3. Миграция legacy приложения
4. Multi-environment setup
5. Disaster recovery процедуры
```

### Сообщество и поддержка

```text
🌐 Полезные ресурсы:
• Docker Community Forums
• Stack Overflow
• GitHub Issues
• Official Docker Blog
• Conference talks (DockerCon, KubeCon)
```

---

</details>

<details>
<summary><b>🎯 Итоговый чеклист</b></summary>

---

### Production Readiness Checklist

```text
✅ Безопасность:
  • Non-root пользователи
  • Regular security scanning
  • Minimal base images
  • No sensitive data in images

✅ Производительность:
  • Multi-stage builds
  • .dockerignore файл
  • Resource limits
  • Optimized layer caching

✅ Надежность:
  • Health checks
  • Proper logging
  • Backup procedures
  • Monitoring setup

✅ Поддержка:
  • Documentation
  • Troubleshooting guides
  • Team training
  • Regular updates
```

### Key Takeaways

```text
🎓 Основные принципы:
• Контейнеры как cattle, не pets
• Идемпотентность и воспроизводимость
• Минимализм и безопасность
• Автоматизация всего

🚀 Production mindset:
• Design for failure
• Monitor everything
• Automate processes
• Continuous improvement
```

### Поздравляем с завершением курса! 🎉

```text
🏆 Вы освоили:
• Основы контейнеризации и Docker
• Создание и оптимизацию образов
• Оркестрацию многоконтейнерных приложений
• Безопасность и мониторинг
• Production best practices

🚀 Дальнейшие шаги:
• Практика на реальных проектах
• Изучение Kubernetes
• Cloud-native development
• Углубление в security и networking
```

---

</details>
