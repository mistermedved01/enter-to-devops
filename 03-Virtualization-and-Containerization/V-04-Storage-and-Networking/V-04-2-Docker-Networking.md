[🏠 Главная](../../README.md) → [🐳 Virtualization-and-Containerization](../../README.md#-virtualization-and-containerization) → [💾 V-04-Storage-and-Networking](../../README.md#-v-04-storage-and-networking)

---

# 🐳V-04-2-Docker-Networking
> Docker Networking: типы сетей, изоляция, подключение контейнеров, DNS, порты и безопасность сетевого взаимодействия.

---

<details>
<summary><b>🎯 Архитектура Docker Networking</b></summary>

---

### Сетевые модели Docker

```text
# Сетевые драйверы Docker
┌─────────────────┐    ┌─────────────────┐
│   bridge        │    │   host          │
│   (default)     │    │   (host net)    │
├─────────────────┤    ├─────────────────┤
│   overlay       │    │   none          │
│   (swarm)       │    │   (no network)  │
├─────────────────┤    ├─────────────────┤
│   macvlan       │    │   ipvlan        │
│   (direct)      │    │   (L3)          │
└─────────────────┘    └─────────────────┘
```

### Сетевые пространства имен

```text
# Каждый контейнер в своем network namespace
┌─────────────────┐    ┌─────────────────┐
│   Контейнер A   │    │   Контейнер B   │
│   eth0: 172.17.0.2 │ │   eth0: 172.17.0.3 │
│   netns: A       │    │   netns: B       │
└─────────────────┘    └─────────────────┘
           ↓                    ↓
    ┌─────────────────────────────────┐
    │        Docker Bridge            │
    │        docker0: 172.17.0.1      │
    └─────────────────────────────────┘
```

**Компоненты сети:**
- ✅ **Network Namespace** - изоляция сети контейнера
- ✅ **veth pair** - виртуальные ethernet устройства
- ✅ **bridge** - виртуальный сетевой коммутатор
- ✅ **iptables** - правила фаервола и NAT

---

</details>

<details>
<summary><b>🌉 Bridge Network</b></summary>

---

### Сеть по умолчанию

```bash
# Просмотр сетей
docker network ls

# Создание bridge сети
docker network create my-bridge-network

# Создание с кастомными настройками
docker network create \
  --driver bridge \
  --subnet=192.168.100.0/24 \
  --gateway=192.168.100.1 \
  my-custom-bridge

# Подключение контейнера к сети
docker run -d --name web \
  --network my-bridge-network \
  nginx:latest
```

### Настройка bridge сети

```bash
# Создание сети с конкретным IP диапазоном
docker network create \
  --subnet=10.10.0.0/16 \
  --ip-range=10.10.10.0/24 \
  --gateway=10.10.10.1 \
  my-network

# Фиксированный IP для контейнера
docker run -d --name app \
  --network my-network \
  --ip 10.10.10.50 \
  nginx:latest

# Просмотр информации о сети
docker network inspect my-network
```

### DNS в bridge сетях

```bash
# Контейнеры могут общаться по именам
docker run -d --name database redis:latest
docker run -it --link database alpine ping database

# Создание алиасов
docker run -d --name web \
  --network my-network \
  --network-alias webserver \
  nginx:latest

# Пинг по алиасу
docker run -it --network my-network alpine ping webserver
```

---

</details>

<details>
<summary><b>🏠 Host Network</b></summary>

---

### Сеть хоста

```bash
# Запуск контейнера в сети хоста
docker run -d \
  --network host \
  nginx:latest

# В этом режиме контейнер использует сеть хоста напрямую
# Порт 80 nginx будет доступен на порту 80 хоста
```

### Особенности host сети

```text
✅ Нет изоляции сети
✅ Прямой доступ к сетевым интерфейсам хоста
✅ Максимальная производительность
❌ Конфликты портов
❌ Отсутствие сетевой изоляции
```

### Сценарии использования

```bash
# Высокопроизводительные приложения
docker run -d --network host nginx:latest

# Сетевые утилиты и мониторинг
docker run -it --network host nicolaka/netshoot

# Приложения требующие RAW сокеты
docker run -d --network host my-custom-app
```

---

</details>

<details>
<summary><b>🚫 None Network</b></summary>

---

### Полная сетевая изоляция

```bash
# Запуск контейнера без сети
docker run -d \
  --network none \
  alpine sleep 3600

# Проверка сети внутри контейнера
docker exec -it <container> ip addr
# Будет только loopback интерфейс
```

### Использование none сети

```text
🔒 Обработка чувствительных данных
📊 Пакетные задания (batch jobs)
🛡️ Повышенные требования безопасности
🔧 Специализированные приложения
```

### Добавление сети позже

```bash
# Запуск без сети
docker run -d --name isolated --network none alpine sleep 3600

# Подключение к сети после запуска
docker network connect my-bridge-network isolated

# Отключение от сети
docker network disconnect my-bridge-network isolated
```

---

</details>

<details>
<summary><b>🔧 Порт и подключения</b></summary>

---

### Проброс портов

```bash
# Проброс порта host:container
docker run -d -p 8080:80 nginx:latest

# Проброс на конкретный IP
docker run -d -p 127.0.0.1:8080:80 nginx:latest

# Проброс случайного порта хоста
docker run -d -p 80 nginx:latest

# Проброс всех портов
docker run -d -P nginx:latest

# Проброс UDP портов
docker run -d -p 53:53/udp dns-server
```

### Сетевые подключения

```bash
# Подключение контейнера к сети
docker network connect my-network my-container

# Отключение от сети
docker network disconnect my-network my-container

# Просмотр сетей контейнера
docker inspect my-container | grep -A 20 Networks
```

### Связи между контейнерами

```bash
# Legacy links (устарело, но работает)
docker run -d --name database redis:latest
docker run -it --link database alpine env

# Современный подход - пользовательские сети
docker network create app-network
docker run -d --name db --network app-network redis:latest
docker run -d --name web --network app-network nginx:latest
# web может пинговать db по имени
```

---

</details>

<details>
<summary><b>🌐 Пользовательские сети</b></summary>

---

### Создание изолированных сетей

```bash
# Создание внутренней сети (без доступа извне)
docker network create \
  --internal \
  --driver bridge \
  my-internal-network

# Сеть с отключенным DNS
docker network create \
  --driver bridge \
  --opt com.docker.network.disable_icc=false \
  my-custom-net

# Просмотр деталей сети
docker network inspect my-custom-net
```

### Macvlan сети

```bash
# Прямое подключение к физической сети
docker network create \
  -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 \
  my-macvlan-net

# Контейнер получит реальный IP в сети
docker run -d \
  --network my-macvlan-net \
  --ip=192.168.1.100 \
  nginx:latest
```

### Overlay сети (для Swarm)

```bash
# Создание overlay сети в Swarm
docker network create \
  --driver overlay \
  --attachable \
  my-overlay-net

# Сервисы в overlay сети
docker service create \
  --name web \
  --network my-overlay-net \
  nginx:latest
```

---

</details>

<details>
<summary><b>🛡️ Сетевая безопасность</b></summary>

---

### Изоляция сетей

```bash
# Создание изолированных сетей для разных приложений
docker network create frontend-net
docker network create backend-net
docker network create database-net

# Контейнеры в разных сетях не видят друг друга
docker run -d --network frontend-net --name frontend nginx:latest
docker run -d --network backend-net --name backend api:latest
docker run -d --network database-net --name database postgres:latest
```

### Ограничение доступа

```bash
# Запрет исходящих подключений
docker run -d \
  --network none \
  --cap-add=NET_ADMIN \
  alpine sh -c "iptables -A OUTPUT -j DROP && sleep 3600"

# Только внутренняя сеть
docker network create --internal secure-net
```

### Мониторинг сети

```bash
# Просмотр сетевых подключений контейнера
docker exec my-container netstat -tulpn

# Анализ трафика
docker run -it --network container:my-container nicolaka/netshoot

# Проверка DNS разрешения
docker exec my-container nslookup database
```

---

</details>

<details>
<summary><b>🔧 Практические сценарии</b></summary>

---

### Многозвенная архитектура

```bash
# Создание сетей для разных уровней
docker network create public-net
docker network create private-net

# Frontend в public сети
docker run -d --name frontend \
  --network public-net \
  -p 80:80 \
  nginx:latest

# Backend в private сети  
docker run -d --name backend \
  --network private-net \
  api:latest

# Подключение frontend к private сети
docker network connect private-net frontend
```

### Разработка с изоляцией

```bash
# Сеть для разработки
docker network create dev-network

# База данных
docker run -d --name postgres-dev \
  --network dev-network \
  -e POSTGRES_PASSWORD=dev \
  postgres:13

# Приложение
docker run -d --name app-dev \
  --network dev-network \
  -p 3000:3000 \
  -e DATABASE_URL=postgres://postgres:dev@postgres-dev:5432/app \
  my-app:dev
```

### Production сеть

```bash
# Внутренняя сеть для коммуникации между сервисами
docker network create --internal service-mesh

# Публичная сеть для доступа извне
docker network create public-frontend

# Балансировщик нагрузки в обеих сетях
docker run -d --name load-balancer \
  --network public-frontend \
  --network service-mesh \
  -p 80:80 \
  haproxy:latest
```

---

</details>

<details>
<summary><b>🎯 Ключевые выводы</b></summary>

---

### Best Practices

```text
✅ Используйте пользовательские bridge сети вместо default
✅ Изолируйте разные компоненты приложения в разные сети
✅ Используйте внутренние сети для sensitive сервисов
✅ Ограничивайте проброс портов только необходимыми
✅ Используйте DNS имена вместо прямых IP адресов
✅ Регулярно проверяйте сетевую безопасность
```

### Выбор сетевого драйвера

```text
🏠 Одиночный хост → bridge, host, none
🌐 Мульти-хост кластер → overlay, macvlan
🔒 Безопасность → внутренние сети, изоляция
⚡ Производительность → host network
```

### Что дальше

```text
📚 Следующая тема: Docker Compose - оркестрация приложений
🔜 Затем: Docker Swarm - кластеризация
🎯 Цель: Создавать безопасные и масштабируемые сетевые архитектуры
```

---

</details>
