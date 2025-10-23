[🏠 Главная](../../README.md) → [🐳 Virtualization-and-Containerization](../../README.md#-virtualization-and-containerization) → [💾 V-04-Storage-and-Networking](../../README.md#-v-04-storage-and-networking)

---

# 🐳V-04-1-Docker-Volumes
> Docker Volumes: управление постоянными данными, типы томов, примонтирование данных, резервное копирование и миграция.

---

<details>
<summary><b>🎯 Что такое Docker Volumes</b></summary>

---

### Проблема эфемерности контейнеров

```text
# Контейнеры по умолчанию эфемерны
┌─────────────────┐    Удаление    ┌─────────────────┐
│   Контейнер     │ ─────────────→ │     Потеря      │
│   (данные)      │                │    данных!      │
└─────────────────┘                └─────────────────┘

# Решение - тома (volumes)
┌─────────────────┐                ┌─────────────────┐
│   Контейнер     │                │      Том        │
│                 │ ←────────────→ │  (сохраняется)  │
└─────────────────┘                └─────────────────┘
```

### Типы хранения данных в Docker

```text
1. 🔄 Volumes - управляемые Docker'ом (рекомендуется)
2. 📁 Bind mounts - монтирование хостовых путей
3. 📄 tmpfs mounts - временное хранилище в памяти
```

**Когда использовать:**
- ✅ **Volumes** - production данные, бэкапы, миграции
- ✅ **Bind mounts** - разработка, конфиги, исходный код
- ✅ **tmpfs** - временные данные, кэш, чувствительная информация

---

</details>

<details>
<summary><b>📦 Docker Volumes</b></summary>

---

### Создание и управление томами

```bash
# Создание тома
docker volume create my-volume

# Просмотр списка томов
docker volume ls

# Детальная информация о томе
docker volume inspect my-volume

# Удаление тома
docker volume rm my-volume

# Очистка неиспользуемых томов
docker volume prune
```

### Использование томов в контейнерах

```bash
# Создание контейнера с томом
docker run -d \
  --name mysql-container \
  -v mysql-data:/var/lib/mysql \
  mysql:latest

# Явное указание драйвера
docker run -d \
  -v my-volume:/app/data \
  --volume-driver local \
  nginx:latest

# Только для чтения
docker run -d \
  -v config-volume:/etc/nginx:ro \
  nginx:latest
```

### Просмотр данных в томах

```bash
# Временный контейнер для доступа к тому
docker run -it --rm \
  -v my-volume:/data \
  alpine ls -la /data

# Копирование файлов в/из тома
docker run --rm \
  -v my-volume:/data \
  -v $(pwd):/backup \
  alpine cp /backup/file.txt /data/

# Просмотр через инспект
docker volume inspect my-volume
```

---

</details>

<details>
<summary><b>📁 Bind Mounts</b></summary>

---

### Монтирование хостовых директорий

```bash
# Монтирование текущей директории
docker run -it \
  -v $(pwd):/app \
  node:16 bash

# Монтирование конкретного пути
docker run -d \
  -v /host/path:/container/path \
  nginx:latest

# Только для чтения
docker run -d \
  -v /host/config:/etc/nginx:ro \
  nginx:latest

# Монтирование файла (не директории)
docker run -d \
  -v /host/nginx.conf:/etc/nginx/nginx.conf \
  nginx:latest
```

### Использование в разработке

```bash
# Hot-reload для Node.js приложения
docker run -d \
  -v $(pwd):/app \
  -p 3000:3000 \
  node:16 npm run dev

# Разработка с Python
docker run -it \
  -v $(pwd):/code \
  -p 8000:8000 \
  python:3.9 python /code/app.py

# База данных с конфигом с хоста
docker run -d \
  -v $(pwd)/mysql.conf:/etc/mysql/conf.d/custom.cnf \
  mysql:latest
```

### Особенности bind mounts

```text
✅ Прямой доступ к файлам на хосте
✅ Изменения видны сразу в контейнере и на хосте
✅ Подходит для разработки и конфигурации
❌ Зависит от файловой системы хоста
❌ Менее портативно чем volumes
```

---

</details>

<details>
<summary><b>💾 tmpfs Mounts</b></summary>

---

### Временное хранилище в памяти

```bash
# Создание tmpfs тома
docker run -d \
  --tmpfs /tmp \
  nginx:latest

# С указанием размера и прав
docker run -d \
  --tmpfs /cache:size=100m,mode=1777 \
  nginx:latest

# Использование в swarm
docker service create \
  --tmpfs /tmp \
  nginx:latest
```

### Сценарии использования

```text
📝 Временные файлы обработки
🔒 Чувствительные данные (пароли, ключи)
🚀 Кэш приложений
🔄 Промежуточные файлы
```

### Сравнение с другими типами

```text
tmpfs vs volumes:
• tmpfs - только в памяти, исчезает при остановке контейнера
• volumes - постоянное хранение на диске

tmpfs vs bind mounts:
• tmpfs - изолирован в контейнере
• bind mounts - доступен с хоста
```

---

</details>

<details>
<summary><b>🔧 Практические сценарии</b></summary>

---

### База данных с постоянным хранилищем

```bash
# PostgreSQL с томом для данных
docker run -d \
  --name postgres \
  -v postgres-data:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=mysecretpassword \
  postgres:13

# MySQL с конфигом и данными
docker run -d \
  --name mysql \
  -v mysql-data:/var/lib/mysql \
  -v $(pwd)/my.cnf:/etc/mysql/conf.d/my.cnf \
  -e MYSQL_ROOT_PASSWORD=secret \
  mysql:8.0
```

### Веб-приложение с статикой

```bash
# Nginx с статическими файлами
docker run -d \
  --name nginx \
  -v static-data:/usr/share/nginx/html \
  -p 80:80 \
  nginx:latest

# Копирование статики в том
docker run --rm \
  -v static-data:/target \
  -v $(pwd)/dist:/source \
  alpine cp -r /source/* /target/
```

### Разработка с hot-reload

```bash
# Node.js разработка
docker run -it \
  --name dev-server \
  -v $(pwd):/app \
  -v /app/node_modules \
  -p 3000:3000 \
  node:16 npm run dev

# Python разработка
docker run -it \
  -v $(pwd):/code \
  -p 8000:8000 \
  python:3.9 \
  bash -c "cd /code && pip install -r requirements.txt && python app.py"
```

---

</details>

<details>
<summary><b>🔄 Резервное копирование и миграция</b></summary>

---

### Бэкап томов

```bash
# Бэкап тома в tar архив
docker run --rm \
  -v mysql-data:/source \
  -v $(pwd):/backup \
  alpine tar czf /backup/mysql-backup.tar.gz -C /source .

# Восстановление из бэкапа
docker run --rm \
  -v mysql-data:/target \
  -v $(pwd):/backup \
  alpine tar xzf /backup/mysql-backup.tar.gz -C /target
```

### Миграция томов между хостами

```bash
# Экспорт тома
docker run --rm \
  -v mysql-data:/data \
  -v $(pwd):/backup \
  alpine tar cf - -C /data . | gzip > mysql-data.tar.gz

# Импорт тома на новом хосте
docker volume create mysql-data
docker run --rm \
  -v mysql-data:/data \
  -v $(pwd):/backup \
  alpine sh -c "tar xzf /backup/mysql-data.tar.gz -C /data"
```

### Копирование данных между томами

```bash
# Создание копии тома
docker volume create mysql-backup
docker run --rm \
  -v mysql-data:/source \
  -v mysql-backup:/target \
  alpine cp -r /source/* /target/
```

---

</details>

<details>
<summary><b>🚀 Продвинутые техники</b></summary>

---

### Volume драйверы

```bash
# Использование NFS драйвера
docker volume create \
  --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.100,rw \
  --opt device=:/path/to/nfs \
  nfs-volume

# SSHFS драйвер
docker volume create \
  --driver vieux/sshfs \
  --opt sshcmd=user@host:/remote/path \
  --opt password=secret \
  ssh-volume
```

### Docker Compose с томами

```yaml
version: '3.8'
services:
  database:
    image: postgres:13
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    environment:
      POSTGRES_PASSWORD: secret

  webapp:
    image: nginx:latest
    volumes:
      - static-data:/usr/share/nginx/html
    ports:
      - "80:80"

volumes:
  postgres-data:
  static-data:
```

### Volume в Docker Swarm

```yaml
version: '3.8'
services:
  database:
    image: postgres:13
    volumes:
      - postgres-data:/var/lib/postgresql/data
    deploy:
      placement:
        constraints:
          - node.labels.db == true

volumes:
  postgres-data:
    driver: local
    driver_opts:
      type: nfs
      o: addr=10.0.0.10,rw
      device: ":/exports/postgres"
```

---

</details>

<details>
<summary><b>🔍 Отладка и мониторинг</b></summary>

---

### Диагностика проблем

```bash
# Просмотр использования томов
docker system df -v

# Проверка примонтированных томов контейнера
docker inspect <container> | grep -A 10 Mounts

# Поиск контейнеров использующих том
docker ps -a --filter volume=my-volume

# Проверка прав доступа
docker run --rm -v my-volume:/data alpine ls -la /data
```

### Восстановление данных

```bash
# Доступ к тому поврежденного контейнера
docker run -it --rm \
  -v mysql-data:/recovery \
  alpine sh

# Создание резервной копии перед удалением
docker run --rm \
  -v mysql-data:/source \
  -v $(pwd):/backup \
  alpine tar czf /backup/emergency-backup.tar.gz -C /source .
```

### Мониторинг использования

```bash
# Скрипт для мониторинга размера томов
docker volume ls -q | while read volume; do
  size=$(docker run --rm -v $volume:/data alpine du -sh /data 2>/dev/null | cut -f1)
  echo "Volume $volume: $size"
done
```

---

</details>

<details>
<summary><b>🎯 Ключевые выводы</b></summary>

---

### Best Practices

```text
✅ Используйте named volumes для production данных
✅ Используйте bind mounts для разработки
✅ Регулярно делайте бэкапы важных томов
✅ Используйте :ro для конфигов только для чтения
✅ Очищайте неиспользуемые тома (volume prune)
✅ Тестируйте восстановление из бэкапов
```

### Выбор типа монтирования

```text
🔧 Разработка → bind mounts
🏭 Production данные → named volumes  
🔒 Временные/чувствительные данные → tmpfs
🌐 Распределенное хранилище → volume drivers (NFS, etc.)
```

### Что дальше

```text
📚 Следующая тема: Docker Networking - сетевое взаимодействие
🔜 Затем: Docker Compose - оркестрация многоконтейнерных приложений
🎯 Цель: Научиться управлять постоянными данными в production
```

---

</details>
