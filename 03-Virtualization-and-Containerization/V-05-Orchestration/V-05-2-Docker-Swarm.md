[🏠 Главная](../../README.md) → [🐳 Virtualization-and-Containerization](../../README.md#-virtualization-and-containerization) → [🎼 V-05-Orchestration](../../README.md#-v-05-orchestration)

---

# 🐳V-05-2-Docker-Swarm
> Docker Swarm: кластеризация, оркестрация контейнеров, сервисы, развертывание и масштабирование в распределенной среде.

---

<details>
<summary><b>🎯 Что такое Docker Swarm</b></summary>

---

### Архитектура Swarm кластера

```text
# Swarm кластер состоит из manager и worker нод
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Manager Node  │    │   Worker Node   │    │   Worker Node   │
│                 │    │                 │    │                 │
│ • Orchestration │    │ • Runs Services │    │ • Runs Services │
│ • API Endpoint  │    │ • Tasks         │    │ • Tasks         │
│ • Raft Consensus│    │ • Containers    │    │ • Containers    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         ↓                       ↓                       ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Overlay Network                              │
│                 (Связь между нодами)                           │
└─────────────────────────────────────────────────────────────────┘
```

### Ключевые концепции Swarm

```text
🏗️  Swarm          - Кластер Docker нод
👑  Manager        - Нода управляющая кластером  
⚙️  Worker         - Нода выполняющая задачи
🚀  Service        - Определение работающего приложения
📦  Task           - Контейнер являющийся частью сервиса
🌐  Overlay Network - Сеть соединяющая ноды кластера
```

**Преимущества Swarm:**
- ✅ **Высокая доступность** - автоматическое восстановление сервисов
- ✅ **Масштабируемость** - легкое добавление/удаление нод
- ✅ **Балансировка нагрузки** - встроенный load balancer
- ✅ **Отказоустойчивость** - репликация сервисов

---

</details>

<details>
<summary><b>🏗️ Создание и управление кластером</b></summary>

---

### Инициализация Swarm

```bash
# Инициализация Swarm на manager ноде
docker swarm init --advertise-addr <MANAGER-IP>

# Просмотр информации о Swarm
docker node ls
docker info | grep -A 10 Swarm

# Получение токена для присоединения worker нод
docker swarm join-token worker

# Получение токена для manager нод
docker swarm join-token manager
```

### Присоединение нод к кластеру

```bash
# На worker ноде выполнить команду из вывода join-token
docker swarm join --token <TOKEN> <MANAGER-IP>:2377

# Просмотр всех нод в кластере
docker node ls

# Детальная информация о ноде
docker node inspect <NODE-ID>

# Обновление метаданных ноды
docker node update --label-add disk=ssd <NODE-ID>
```

### Управление кластером

```bash
# Покинуть Swarm (на worker ноде)
docker swarm leave

# Покинуть Swarm (на manager ноде)
docker swarm leave --force

# Удалить ноду из кластера
docker node rm <NODE-ID>

# Демотировать manager до worker
docker node demote <NODE-ID>

# Промоутить worker до manager
docker node promote <NODE-ID>
```

---

</details>

<details>
<summary><b>🚀 Управление сервисами</b></summary>

---

### Создание и масштабирование сервисов

```bash
# Создание сервиса
docker service create --name web nginx:alpine

# Создание сервиса с пробросом портов
docker service create \
  --name web \
  --publish published=80,target=80 \
  nginx:alpine

# Масштабирование сервиса
docker service scale web=5

# Просмотр сервисов
docker service ls

# Детальная информация о сервисе
docker service inspect web
```

### Продвинутые настройки сервисов

```bash
# Создание сервиса с репликами
docker service create \
  --name api \
  --replicas 3 \
  --update-parallelism 2 \
  --update-delay 10s \
  my-api:latest

# Сервис с глобальной репликацией (на каждой ноде)
docker service create \
  --name monitoring \
  --mode global \
  prom/node-exporter

# Сервис с ограничениями ресурсов
docker service create \
  --name app \
  --limit-memory 512M \
  --reserve-memory 256M \
  my-app:latest
```

### Обновление и откат сервисов

```bash
# Обновление образа сервиса
docker service update --image my-app:v2.0 app

# Откат к предыдущей версии
docker service rollback app

# Обновление с настройками
docker service update \
  --image my-app:v3.0 \
  --update-parallelism 1 \
  --update-delay 30s \
  --update-failure-action rollback \
  app

# Принудительное обновление
docker service update --force app
```

---

</details>

<details>
<summary><b>🌐 Сети в Swarm</b></summary>

---

### Overlay сети

```bash
# Создание overlay сети
docker network create \
  --driver overlay \
  --attachable \
  my-overlay-net

# Создание внутренней overlay сети
docker network create \
  --driver overlay \
  --internal \
  private-net

# Просмотр сетей в Swarm
docker network ls

# Подключение сервиса к сети
docker service create \
  --name web \
  --network my-overlay-net \
  nginx:alpine
```

### Сервисное обнаружение и балансировка

```text
# Встроенный DNS и load balancing
┌─────────────────┐    ┌─────────────────┐
│   Service A     │    │   Service B     │
│   (3 replicas)  │    │   (2 replicas)  │
└─────────────────┘    └─────────────────┘
         ↓                       ↓
┌─────────────────────────────────────────┐
│          Internal Load Balancer         │
│          + DNS Round Robin              │
└─────────────────────────────────────────┘
```

```bash
# Сервисы могут общаться по имени
docker service create --name database redis:alpine
docker service create --name app --network my-overlay-net my-app:latest
# app может подключиться к database по имени
```

---

</details>

<details>
<summary><b>💾 Хранение данных в Swarm</b></summary>

---

### Тома и конфиги

```bash
# Создание тома
docker volume create app-data

# Использование тома в сервисе
docker service create \
  --name database \
  --mount type=volume,source=app-data,target=/data \
  postgres:13

# Создание конфига
echo "config data" | docker config create my-config -

# Использование конфига в сервисе
docker service create \
  --name app \
  --config source=my-config,target=/app/config.json \
  my-app:latest
```

### Секреты

```bash
# Создание секрета из файла
docker secret create db-password ./password.txt

# Создание секрета из stdin
echo "secret123" | docker secret create api-key -

# Использование секрета в сервисе
docker service create \
  --name app \
  --secret source=db-password,target=/run/secrets/db_password \
  my-app:latest

# Просмотр секретов
docker secret ls
```

### Внешние хранилища

```bash
# Использование NFS томов
docker service create \
  --name app \
  --mount \
    type=volume,\
    source=nfs-volume,\
    target=/app/data,\
    volume-driver=local,\
    volume-opt=type=nfs,\
    volume-opt=device=:/nfs/share,\
    volume-opt=o=addr=192.168.1.100 \
  my-app:latest
```

---

</details>

<details>
<summary><b>⚙️ Размещение и ограничения</b></summary>

---

### Размещение сервисов

```bash
# Размещение на manager нодах
docker service create \
  --name app \
  --constraint node.role==manager \
  my-app:latest

# Размещение по меткам
docker service create \
  --name app \
  --constraint node.labels.storage==ssd \
  my-app:latest

# Размещение на конкретной ноде
docker service create \
  --name app \
  --constraint node.hostname==node-1 \
  my-app:latest
```

### Режимы репликации

```bash
# Replicated mode (по умолчанию)
docker service create \
  --name web \
  --replicas 3 \
  nginx:alpine

# Global mode (на каждой ноде)
docker service create \
  --name monitoring \
  --mode global \
  prom/node-exporter

# Комбинация с ограничениями
docker service create \
  --name app \
  --mode global \
  --constraint node.labels.env==production \
  my-app:latest
```

### Ресурсы и политики

```bash
# Ограничение ресурсов
docker service create \
  --name app \
  --limit-cpu 2 \
  --limit-memory 1G \
  --reserve-cpu 1 \
  --reserve-memory 512M \
  my-app:latest

# Политика перезапуска
docker service create \
  --name app \
  --restart-condition on-failure \
  --restart-delay 5s \
  --restart-max-attempts 3 \
  my-app:latest
```

---

</details>

<details>
<summary><b>🏗️ Docker Stack</b></summary>

---

### Развертывание приложений через stack

```yaml
# docker-compose.yml для Swarm
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - target: 80
        published: 80
        protocol: tcp
        mode: host
    deploy:
      replicas: 3
      update_config:
        parallelism: 2
        delay: 10s
      restart_policy:
        condition: on-failure
      resources:
        limits:
          memory: 256M
        reservations:
          memory: 128M

  database:
    image: postgres:13
    environment:
      POSTGRES_PASSWORD: secret
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:

networks:
  default:
    driver: overlay
```

### Команды управления stack

```bash
# Развертывание stack
docker stack deploy -c docker-compose.yml my-app

# Просмотр stack
docker stack ls
docker stack services my-app
docker stack ps my-app

# Удаление stack
docker stack rm my-app

# Масштабирование сервиса в stack
docker service scale my-app_web=5
```

### Секреты и конфиги в stack

```yaml
version: '3.8'

services:
  app:
    image: my-app:latest
    secrets:
      - db-password
    configs:
      - app-config

secrets:
  db-password:
    external: true

configs:
  app-config:
    file: ./config.json

networks:
  default:
    driver: overlay
```

---

</details>

<details>
<summary><b>🔧 Мониторинг и отладка</b></summary>

---

### Мониторинг кластера

```bash
# Просмотр состояния нод
docker node ls

# Просмотр задач сервиса
docker service ps web

# Просмотр логов сервиса
docker service logs -f web

# Проверка здоровья сервиса
docker service inspect --pretty web

# Мониторинг событий
docker events --filter type=service
```

### Отладка проблем

```bash
# Проверка сетевых подключений
docker network inspect my-overlay-net

# Проверка размещения задач
docker service ps web --no-trunc

# Просмотр деталей задачи
docker inspect <TASK-ID>

# Проверка доступности сервиса
curl http://$(docker node inspect self --format '{{ .Status.Addr }}'):80
```

### Резервное копирование и восстановление

```bash
# Бэкап томов Swarm
docker run --rm -v app-data:/source -v $(pwd):/backup alpine \
  tar czf /backup/app-data.tar.gz -C /source .

# Бэкап конфигов и секретов
docker config ls -q | xargs -I {} docker config inspect {} > configs-backup.json
docker secret ls -q | xargs -I {} docker secret inspect {} > secrets-backup.json
```

---

</details>

<details>
<summary><b>🎯 Ключевые выводы</b></summary>

---

### Best Practices для Production

```text
✅ Используйте нечетное количество manager нод (3, 5, 7)
✅ Разделяйте manager и worker ноды по ролям
✅ Используйте overlay сети для межсервисного взаимодействия
✅ Настройте мониторинг и алертинг для кластера
✅ Регулярно делайте бэкапы томов и конфигов
✅ Используйте секреты для хранения чувствительных данных
✅ Настраивайте политики обновления для zero-downtime деплоев
```

### Когда использовать Swarm

```text
🏢 Enterprise приложения - отказоустойчивость и масштабируемость
🌐 Микросервисные архитектуры - встроенная балансировка нагрузки
📊 High Availability - автоматическое восстановление сервисов
🔧 Простота управления - встроена в Docker, легче чем Kubernetes
```

### Что дальше

```text
📚 Следующая тема: Docker безопасность - защита контейнеров и кластеров
🔜 Затем: Мониторинг и логи - наблюдение за приложениями
🎯 Цель: Создавать отказоустойчивые и масштабируемые production-кластеры
```

---

</details>
