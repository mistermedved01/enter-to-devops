[🏠 Главная](../../README.md) → [🐳 Virtualization-and-Containerization](../../README.md#-virtualization-and-containerization) → [📦 V-02-Images-and-Containers](../../README.md#-v-02-images-and-containers)

---

# 🐳V-02-2-Docker-Containers
> Docker Containers: запуск, управление, мониторинг и отладка контейнеров. Жизненный цикл контейнера, интерактивный режим, переменные окружения.

---

<details>
<summary><b>🎯Что такое Docker Container</b></summary>

---

### Основные понятия

```text
# Docker Container - запущенный экземпляр образа

┌─────────────────────────────────┐
│         Контейнер               │
│        (running nginx)          │
├─────────────────────────────────┤
│  Read-write слой (контейнер)    │
├─────────────────────────────────┤
│  Read-only слои (образ)         │
│  +───────────────────────────+  │
│  │    App & Config           │  │
│  +───────────────────────────+  │
│  │    Dependencies           │  │
│  +───────────────────────────+  │
│  │    Base Image             │  │
│  +───────────────────────────+  │
└─────────────────────────────────┘
```

**Ключевые характеристики:**
- ✅ **Изолированные** - собственное пространство процессов, сети, файлов
- ✅ **Эфемерные** - данные теряются при удалении контейнера
- ✅ **Легковесные** - быстрый запуск и остановка
- ✅ **Портативные** - одинаково работают на любой системе с Docker

### Жизненный цикл контейнера

```text
Создан (created) → Запущен (running) → Остановлен (stopped) → Удален (removed)
     ↓                    ↓                   ↓
docker create    docker start       docker stop     docker rm
docker run                              docker restart
```

---

</details>

<details>
<summary><b>🚀Запуск контейнеров</b></summary>

---

### Основные команды запуска

```bash
# Запуск контейнера в фоновом режиме
docker run -d nginx:latest

# Запуск с именем
docker run -d --name my-nginx nginx:latest

# Запуск с пробросом портов
docker run -d -p 8080:80 nginx:latest

# Запуск с пробросом всех портов
docker run -d -P nginx:latest

# Запуск и автоматическое удаление после остановки
docker run -d --rm nginx:latest
```

### Интерактивный режим

```bash
# Запуск в интерактивном режиме с терминалом
docker run -it ubuntu:latest /bin/bash

# Запуск с подключением к STDIN
docker run -i ubuntu:latest cat

# Комбинированный режим
docker run -it --name my-container ubuntu:latest
```

### Переменные окружения

```bash
# Установка переменных окружения
docker run -d -e "ENV=production" -e "DEBUG=false" nginx:latest

# Чтение переменных из файла
docker run -d --env-file .env nginx:latest

# Просмотр переменных окружения запущенного контейнера
docker exec my-container env
```

---

</details>

<details>
<summary><b>⚙️Управление контейнерами</b></summary>

---

### Мониторинг состояния

```bash
# Просмотр запущенных контейнеров
docker ps

# Просмотр всех контейнеров (включая остановленные)
docker ps -a

# Просмотр последнего созданного контейнера
docker ps -l

# Просмотр только ID контейнеров
docker ps -q

# Просмотр с форматированием вывода
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Управление жизненным циклом

```bash
# Остановка контейнера
docker stop my-container

# Принудительная остановка
docker kill my-container

# Перезапуск контейнера
docker restart my-container

# Пауза контейнера
docker pause my-container

# Возобновление контейнера
docker unpause my-container

# Удаление контейнера
docker rm my-container

# Принудительное удаление запущенного контейнера
docker rm -f my-container
```

### Пакетные операции

```bash
# Остановка всех контейнеров
docker stop $(docker ps -q)

# Удаление всех остановленных контейнеров
docker container prune

# Удаление всех контейнеров (опасно!)
docker rm -f $(docker ps -aq)
```

---

</details>

<details>
<summary><b>🔍Работа с запущенными контейнерами</b></summary>

---

### Выполнение команд внутри контейнера

```bash
# Выполнение команды в запущенном контейнере
docker exec my-container ls -la

# Интерактивное подключение к контейнеру
docker exec -it my-container /bin/bash

# Выполнение команды от имени определенного пользователя
docker exec -it --user root my-container /bin/bash

# Создание интерактивной сессии
docker exec -it my-container sh
```

### Просмотр логов и информации

```bash
# Просмотр логов в реальном времени
docker logs -f my-container

# Просмотр последних N строк
docker logs --tail 100 my-container

# Просмотр логов с временными метками
docker logs -tf my-container

# Просмотр детальной информации о контейнере
docker inspect my-container

# Просмотр конкретной информации
docker inspect --format='{{.NetworkSettings.IPAddress}}' my-container
```

### Копирование файлов

```bash
# Копирование файла из контейнера на хост
docker cp my-container:/etc/nginx/nginx.conf ./nginx.conf

# Копирование файла с хоста в контейнер
docker cp ./config.json my-container:/app/config.json

# Копирование директории
docker cp my-container:/var/log/nginx/ ./logs/
```

---

</details>

<details>
<summary><b>📊Мониторинг и ресурсы</b></summary>

---

### Мониторинг производительности

```bash
# Просмотр статистики в реальном времени
docker stats

# Просмотр статистики конкретных контейнеров
docker stats my-container1 my-container2

# Просмотр статистики без потокового вывода
docker stats --no-stream

# Просмотр процессов внутри контейнера
docker top my-container
```

### Ограничение ресурсов

```bash
# Ограничение памяти
docker run -d --memory=512m nginx:latest

# Ограничение CPU
docker run -d --cpus=1.5 nginx:latest

# Ограничение CPU через shares
docker run -d --cpu-shares=512 nginx:latest

# Ограничение памяти + swap
docker run -d --memory=512m --memory-swap=1g nginx:latest

# Ограничение I/O
docker run -d --device-read-bps /dev/sda:1mb nginx:latest
```

### Проверка здоровья

```bash
# Просмотр информации о ресурсах
docker system df

# Проверка дискового использования
docker system df -v

# Просмотр событий Docker
docker system events
```

---

</details>

<details>
<summary><b>🎯Практические сценарии</b></summary>

---

### Отладка и диагностика

```bash
# Сценарий 1: Диагностика проблем с запуском
docker logs my-container
docker inspect my-container
docker exec -it my-container bash

# Сценарий 2: Анализ использования ресурсов
docker stats my-container
docker top my-container
docker exec my-container ps aux

# Сценарий 3: Резервное копирование данных
docker commit my-container my-backup:$(date +%Y%m%d)
docker save -o my-backup.tar my-backup:latest
```

### Разработка и тестирование

```bash
# Сценарий 1: Разработка с hot-reload
docker run -d -v $(pwd):/app -p 3000:3000 node:latest

# Сценарий 2: Тестирование в изолированном окружении
docker run --rm -it -v $(pwd):/test ubuntu:latest /test/run-tests.sh

# Сценарий 3: Временная база данных для тестов
docker run -d --rm --name test-db -e POSTGRES_PASSWORD=test postgres:latest
```

### Автоматизация

```bash
# Скрипт для очистки остановленных контейнеров
docker container prune -f

# Скрипт для перезапуска всех контейнеров
docker restart $(docker ps -q)

# Скрипт для бэкапа конфигураций
docker cp my-container:/etc/nginx/ ./backup/nginx-$(date +%Y%m%d)
```

---

</details>

<details>
<summary><b>⚠️Распространенные ошибки</b></summary>

---

### Проблемы и решения

```text
❌"Port is already allocated"
✅Используйте другой порт или остановите конфликтующий контейнер

❌"Container name is already in use"  
✅Используйте другое имя или удалите старый контейнер

❌"Cannot connect to the Docker daemon"
✅Проверьте, запущен ли Docker демон

❌"No such container"
✅Проверьте правильность имени контейнера через docker ps -a

❌"Permission denied"
✅Используйте sudo или добавьте пользователя в группу docker
```

### Best Practices

```text
✅Всегда используйте --rm для временных контейнеров
✅Давайте осмысленные имена контейнерам (--name)
✅Используйте конкретные версии образов, не latest
✅Ограничивайте ресурсы в production
✅Регулярно очищайте остановленные контейнеры
✅Используйте .dockerignore для уменьшения контекста сборки
```

---

</details>

<details>
<summary><b>🎯Ключевые выводы</b></summary>

---

### Основные концепции

```text
1. 🚀Контейнеры - это запущенные экземпляры образов
2. ⚡Быстрый запуск и остановка благодаря слоистой архитектуре  
3. 🔄Эфемерная природа - данные теряются при удалении
4. 🛠️Полный контроль через CLI команды
5. 📊Мониторинг ресурсов в реальном времени
```

---

</details>

