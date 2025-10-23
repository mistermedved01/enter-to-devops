[🏠 Главная](../../README.md) → [🐳 Virtualization-and-Containerization](../../README.md#-virtualization-and-containerization) → [🎼 V-05-Orchestration](../../README.md#-v-05-orchestration)

---

# 🐳V-05-1-Docker-Compose
> Docker Compose: оркестрация многоконтейнерных приложений, управление сервисами, сети, тома и переменные окружения.

---

<details>
<summary><b>🎯 Что такое Docker Compose</b></summary>

---

### Проблема управления множеством контейнеров

```text
# Без Compose - множество команд
docker run -d --name db -v db_data:/data postgres:13
docker run -d --name redis redis:alpine  
docker run -d --name app -p 80:80 -e DB_URL=... my-app:latest
docker run -d --name nginx -p 443:443 nginx:latest

# С Compose - один файл и одна команда
docker-compose up -d
```

### Архитектура Docker Compose

```text
# Compose управляет всем приложением
┌─────────────────────────────────┐
│       docker-compose.yml        │
├─────────────────────────────────┤
│ services:                       │
│   - database                    │
│   - cache                       │
│   - backend                     │
│   - frontend                    │
│   - proxy                       │
└─────────────────────────────────┘
           ↓
    docker-compose up
```

**Преимущества Compose:**
- ✅ **Декларативная конфигурация** - один файл для всего приложения
- ✅ **Воспроизводимость** - одинаково работает везде
- ✅ **Упрощение** - одна команда вместо множества docker run
- ✅ **Интеграция** - сети, тома, переменные окружения

---

</details>

<details>
<summary><b>📝 Структура docker-compose.yml</b></summary>

---

### Базовая структура файла

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    depends_on:
      - api

  api:
    image: my-api:latest
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/app

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: app
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:
```

### Версии Compose

```text
Compose File Format Versions:
• 3.8 - текущая стабильная (рекомендуется)
• 3.0 - минимальная для новых проектов
• 2.4 - устаревшая, но поддерживается

Docker Compose Versions:
• v2 (docker compose) - новая версия, встроена в Docker
• v1 (docker-compose) - старая версия, отдельная установка
```

### Основные секции файла

```yaml
version: '3.8'           # Версия формата

services:                # Определение сервисов
  web: ...               # Контейнеры приложения
  db: ...

networks: ...            # Пользовательские сети
volumes: ...             # Управление томами
configs: ...             # Конфигурации (Swarm)
secrets: ...             # Секреты (Swarm)
```

---

</details>

<details>
<summary><b>🚀 Управление сервисами</b></summary>

---

### Основные команды Compose

```bash
# Запуск всех сервисов
docker-compose up -d

# Остановка всех сервисов
docker-compose down

# Просмотр статуса сервисов
docker-compose ps

# Просмотр логов
docker-compose logs
docker-compose logs -f web  # логи конкретного сервиса

# Перезапуск сервиса
docker-compose restart web

# Выполнение команды в сервисе
docker-compose exec web bash
```

### Управление отдельными сервисами

```bash
# Запуск только определенных сервисов
docker-compose up -d web db

# Масштабирование сервиса
docker-compose up -d --scale web=3

# Пересборка и перезапуск
docker-compose up -d --build

# Принудительная пересборка
docker-compose build --no-cache
```

### Мониторинг и отладка

```bash
# Проверка конфигурации
docker-compose config

# Просмотр использования ресурсов
docker-compose top

# Просмотр переменных окружения
docker-compose exec web env

# Проверка здоровья сервисов
docker-compose ps --services
```

---

</details>

<details>
<summary><b>⚙️ Конфигурация сервисов</b></summary>

---

### Образы и сборка

```yaml
services:
  # Использование готового образа
  nginx:
    image: nginx:alpine

  # Сборка из Dockerfile
  app:
    build: 
      context: .
      dockerfile: Dockerfile
      args:
        BUILD_ENV: production

  # Сборка с кастомным именем
  custom-app:
    build: ./app-directory
    image: my-registry/app:latest
```

### Порт и сети

```yaml
services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"                    # host:container
      - "443:443"
      - "8080"                     # случайный порт хоста
    networks:
      - frontend
      - backend

  api:
    image: node:16
    expose:
      - "3000"                     # только для других контейнеров
    networks:
      - backend

networks:
  frontend:
  backend:
    driver: bridge
```

### Переменные окружения

```yaml
services:
  database:
    image: postgres:13
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    env_file:
      - .env
      - db.env

  app:
    image: my-app:latest
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:password@database:5432/myapp
```

---

</details>

<details>
<summary><b>💾 Тома и данные</b></summary>

---

### Конфигурация томов

```yaml
services:
  database:
    image: postgres:13
    volumes:
      # Named volume
      - db_data:/var/lib/postgresql/data
      
      # Bind mount
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
      
      # Read-only volume
      - config:/etc/config:ro
      
      # Volume с опциями
      - logs:/var/log:rw

  app:
    image: node:16
    volumes:
      # Volume для node_modules (изоляция от хоста)
      - node_modules:/app/node_modules
      
      # Hot-reload для разработки
      - .:/app

volumes:
  db_data:
  node_modules:
  logs:
    driver: local
```

### Volume драйверы и опции

```yaml
volumes:
  nfs_volume:
    driver: local
    driver_opts:
      type: nfs
      o: addr=192.168.1.100,rw
      device: ":/path/to/nfs"

  backup_volume:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /mnt/backup
```

---

</details>

<details>
<summary><b>🔧 Продвинутые техники</b></summary>

---

### Зависимости и порядок запуска

```yaml
services:
  web:
    image: nginx:alpine
    depends_on:
      - api
      - cache
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 30s
      timeout: 10s
      retries: 3

  api:
    image: node:16
    depends_on:
      database:
        condition: service_healthy

  database:
    image: postgres:13
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5
```

### Ресурсы и ограничения

```yaml
services:
  app:
    image: my-app:latest
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M

    # Ограничения (только для docker-compose)
    mem_limit: 512m
    mem_reservation: 256m
    cpus: 1.0

    # Перезапуск при падении
    restart: unless-stopped
```

### Профили и окружения

```yaml
services:
  web:
    image: nginx:alpine
    profiles: ["production"]

  dev-tools:
    image: node:16
    profiles: ["development"]
    volumes:
      - .:/app

  database:
    image: postgres:13
    # Без профиля - запускается всегда
```

```bash
# Запуск с определенными профилями
docker-compose --profile development up -d
docker-compose --profile production up -d
```

---

</details>

<details>
<summary><b>🏗️ Практические примеры</b></summary>

---

### Веб-приложение (LAMP stack)

```yaml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
      - php-sockets:/var/run/php
    depends_on:
      - php

  php:
    image: php:8.1-fpm
    volumes:
      - .:/var/www/html
      - php-sockets:/var/run/php
    environment:
      - DB_HOST=database

  database:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpass
      MYSQL_DATABASE: app
      MYSQL_USER: appuser
      MYSQL_PASSWORD: apppass
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
  php-sockets:
```

### Микросервисная архитектура

```yaml
version: '3.8'

services:
  gateway:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./gateway.conf:/etc/nginx/nginx.conf
    networks:
      - public

  auth-service:
    image: auth-service:latest
    networks:
      - public
      - private
    environment:
      - REDIS_URL=redis://redis:6379

  user-service:
    image: user-service:latest
    networks:
      - private
    environment:
      - DATABASE_URL=postgresql://postgres:pass@db:5432/users

  redis:
    image: redis:alpine
    networks:
      - private

  db:
    image: postgres:13
    networks:
      - private
    environment:
      POSTGRES_PASSWORD: pass

networks:
  public:
  private:
    internal: true
```

### Разработка с hot-reload

```yaml
version: '3.8'

services:
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    environment:
      - CHOKIDAR_USEPOLLING=true
    command: npm run dev

  backend:
    build: ./backend
    ports:
      - "8000:8000"
    volumes:
      - ./backend:/app
    environment:
      - DEBUG=1
    command: python manage.py runserver 0.0.0.0:8000

  database:
    image: postgres:13
    environment:
      POSTGRES_DB: devdb
      POSTGRES_USER: devuser
      POSTGRES_PASSWORD: devpass
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:
```

---

</details>

<details>
<summary><b>🔧 Отладка и оптимизация</b></summary>

---

### Отладка проблем

```bash
# Проверка синтаксиса
docker-compose config

# Подробный вывод при запуске
docker-compose up --verbose

# Запуск в foreground для отладки
docker-compose up

# Просмотр логов конкретного сервиса
docker-compose logs -f --tail=100 web

# Проверка сетевых подключений
docker-compose exec web nslookup database
```

### Оптимизация для production

```yaml
services:
  app:
    build: .
    # Явное указание платформы
    platform: linux/amd64
    
    # Ограничение ресурсов
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1.0'
    
    # Политика перезапуска
    restart: unless-stopped
    
    # Health checks
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

### Мульти-файловая конфигурация

```bash
# Базовый файл
docker-compose.yml

# Переопределения для разработки
docker-compose.override.yml

# Production конфигурация  
docker-compose.prod.yml
```

```yaml
# docker-compose.override.yml
version: '3.8'

services:
  app:
    volumes:
      - .:/app  # Hot-reload для разработки
    environment:
      - DEBUG=1
```

```bash
# Использование разных файлов
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

---

</details>

<details>
<summary><b>🎯 Ключевые выводы</b></summary>

---

### Best Practices

```text
✅ Используйте версию 3.8 формата
✅ Разделяйте сервисы по сетям для изоляции
✅ Используйте health checks для управления зависимостями
✅ Храните секреты в .env файлах (не в репозитории)
✅ Используйте named volumes для production данных
✅ Настройте ограничения ресурсов
✅ Используйте профили для разных окружений
```

### Команды для ежедневного использования

```text
🚀 docker-compose up -d          # Запуск
🛑 docker-compose down           # Остановка  
📊 docker-compose ps             # Статус
📝 docker-compose logs -f        # Логи
🔧 docker-compose exec service   # Выполнение команд
🔄 docker-compose restart        # Перезапуск
```

### Что дальше

```text
📚 Следующая тема: Docker Swarm - кластеризация и оркестрация
🔜 Затем: Docker безопасность - защита контейнеров
🎯 Цель: Управлять сложными приложениями через декларативную конфигурацию
```

---

</details>
