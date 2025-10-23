[🏠 Главная](../../README.md) → [🐳 Virtualization-and-Containerization](../../README.md#-virtualization-and-containerization) → [📦 V-02-Images-and-Containers](../../README.md#-v-02-images-and-containers)

---

# 🐳V-02-1-Docker-Images
> Docker Images: создание, управление, структура и работа с образами. Слоистая архитектура, тегирование, работа с реестрами.

---

<details>
<summary><b>🎯 Что такое Docker Image</b></summary>

---

### Основные понятия

```text
# Docker Image - неизменяемый шаблон для создания контейнеров

┌─────────────────────────────────┐
│        Docker Image             │
│        (nginx:latest)           │
├─────────────────────────────────┤
│  Read-only слои                 │
│  +───────────────────────────+  │
│  │    App & Config           │ ← Layer 4
│  +───────────────────────────+  │
│  │    Dependencies           │ ← Layer 3  
│  +───────────────────────────+  │
│  │    Runtime Environment    │ ← Layer 2
│  +───────────────────────────+  │
│  │    Base OS                │ ← Layer 1
│  +───────────────────────────+  │
└─────────────────────────────────┘
```

**Ключевые характеристики:**
- ✅ **Immutable** - неизменяемые после создания
- ✅ **Слоистые** - состоят из read-only слоев
- ✅ **Версионность** - теги для разных версий
- ✅ **Портативные** - работают везде, где есть Docker

### Аналогия с программированием

```text
Класс (Image) → Экземпляр класса (Container)
    ↓                    ↓
Шаблон              Запущенный процесс
```

---

</details>

<details>
<summary><b>📦Структура образа</b></summary>

---

### Слоистая архитектура

```text
# Каждый слой - это изменение файловой системы

┌─────────────────┐
│   Контейнер     │
│   (read-write)  │ ← Read-write слой
├─────────────────┤
│   Слой: config  │ ← Read-only
├─────────────────┤
│   Слой: app     │ ← Read-only  
├─────────────────┤
│   Слой: deps    │ ← Read-only
├─────────────────┤
│   Слой: base    │ ← Read-only
└─────────────────┘
```

**Преимущества слоев:**
- 🚀 **Эффективное хранение** - общие слои переиспользуются
- ⚡ **Быстрая загрузка** - скачиваются только отсутствующие слои
- 🔄 **Кэширование сборки** - неизмененные слои не пересобираются

### Просмотр слоев образа

```bash
# Просмотр истории образа (слои)
docker image history nginx:latest

# Детальная информация об образе
docker image inspect nginx:latest

# Просмотр размера образов
docker image ls
```

---

</details>

<details>
<summary><b>🏷️Тегирование образов</b></summary>

---

### Синтаксис тегов

```bash
# Формат имени образа:
[registry/][username/]name:tag

Примеры:
nginx:latest                    # Официальный образ
nginx:1.21-alpine              # Конкретная версия
mycompany/app:v1.2.3          # Кастомный образ
localhost:5000/myapp:dev       # Локальный registry
```

### Работа с тегами

```bash
# Скачать образ с тегом
docker pull nginx:1.21-alpine

# Тегирование существующего образа
docker tag nginx:latest my-nginx:v1

# Просмотр всех тегов образа
docker image ls nginx

# Поиск тегов в Docker Hub
docker search nginx --filter is-official=true
```

### Best Practices тегирования

```text
✅Используйте семантическое версионирование: v1.2.3
✅Тег latest для последней стабильной версии  
✅Указывайте конкретные версии для production
✅Используйте теги для разных окружений: dev, staging, prod
```

---

</details>

<details>
<summary><b>📥Загрузка и скачивание</b></summary>

---

### Работа с Docker Hub

```bash
# Скачать образ из registry
docker pull nginx:latest

# Загрузить образ в registry
docker push myusername/myapp:v1.0

# Войти в Docker Hub
docker login

# Выйти из Docker Hub
docker logout

# Скачать все теги образа
docker pull --all-tags nginx
```

### Локальные registry

```bash
# Запуск локального registry
docker run -d -p 5000:5000 --name registry registry:2

# Тегирование для локального registry
docker tag myapp:latest localhost:5000/myapp:latest

# Загрузка в локальный registry  
docker push localhost:5000/myapp:latest

# Скачивание из локального registry
docker pull localhost:5000/myapp:latest
```

---

</details>

<details>
<summary><b>🛠️Управление образами</b></summary>

---

### Основные команды

```bash
# Просмотр локальных образов
docker image ls
docker images

# Поиск образов
docker search nginx

# Получение информации об образе
docker image inspect nginx:latest

# Удаление образа
docker image rm nginx:latest
docker rmi nginx:latest

# Принудительное удаление
docker rmi -f nginx:latest

# Очистка неиспользуемых образов
docker image prune
```

### Фильтрация образов

```bash
# Фильтрация по имени
docker image ls --filter reference="nginx*"

# Фильтрация до/после создания
docker image ls --filter "before=nginx:latest"
docker image ls --filter "since=nginx:latest"

# Фильтрация dangling образов
docker image ls --filter dangling=true

# Показать только ID образов
docker image ls -q
```

---

</details>

<details>
<summary><b>🔍Анализ образов</b></summary>

---

### Исследование содержимого

```bash
# Просмотр истории сборки
docker history nginx:latest

# Просмотр слоев в деталях
docker image inspect nginx:latest --format='{{.RootFS.Layers}}'

# Анализ размера
docker system df

# Детальный анализ образа (требуется dive)
dive nginx:latest
```

### Создание образа из контейнера

```bash
# Создать образ из запущенного контейнера
docker commit my-container my-image:latest

# С указанием автора и сообщения
docker commit -a "Your Name" -m "Added config" my-container my-image:v2
```

---

</details>

<details>
<summary><b>🚀 Практические примеры</b></summary>

---

### Работа с образами в реальных сценариях

```bash
# Сценарий 1: Миграция образа между серверами
docker save -o nginx.tar nginx:latest
# Переносим файл и загружаем:
docker load -i nginx.tar

# Сценарий 2: Экспорт/импорт
docker export my-container > container.tar
docker import container.tar my-image:imported

# Сценарий 3: Сравнение образов
docker image inspect image1 > image1.json
docker image inspect image2 > image2.json
diff image1.json image2.json
```

### Оптимизация работы с образами

```bash
# Использование .dockerignore для уменьшения размера
echo "node_modules" >> .dockerignore
echo ".git" >> .dockerignore
echo "*.log" >> .dockerignore

# Многостадийные сборки для минимизации размера
# (будет рассмотрено в Dockerfile)
```

---

</details>

<details>
<summary><b>🎯Ключевые выводы</b></summary>

---

### Основные концепции

```text
1. 📦Образы - это шаблоны для контейнеров
2. 🏗️Слоистая архитектура обеспечивает эффективность  
3. 🏷️Тегирование позволяет управлять версиями
4. 🔄Registry - централизованное хранение образов
5. 💾Локальное управление - основа workflow
```

### Best Practices

```text
✅Используйте конкретные теги версий в production
✅Регулярно очищайте неиспользуемые образы
✅Используйте .dockerignore для уменьшения размера
✅Анализируйте слои для оптимизации сборки
✅Используйте семантическое версионирование
```

---

</details>
