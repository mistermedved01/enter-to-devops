[🏠 Главная](../../README.md) → [🐳 Virtualization-and-Containerization](../../README.md#-virtualization-and-containerization) → [📝 V-03-Dockerfile](../../README.md#-v-03-dockerfile)

---

# 🐳V-03-1-Dockerfile-Основы
> Dockerfile: синтаксис, инструкции, создание собственных образов. Базовые принципы написания Dockerfile, многостадийные сборки.

---

<details>
<summary><b>🎯Что такое Dockerfile</b></summary>

---

### Основные понятия

```text
# Dockerfile - текстовый файл с инструкциями для сборки образа
┌─────────────────────────────────┐
│         Dockerfile              │
├─────────────────────────────────┤
│ FROM ubuntu:20.04               │
│ RUN apt update && apt install -y│
│   python3 python3-pip           │
│ COPY . /app                     │
│ WORKDIR /app                    │
│ RUN pip install -r requirements.│
│ CMD ["python3", "app.py"]       │
└─────────────────────────────────┘
```

**Ключевые характеристики:**
- ✅ **Декларативный** - описывает что, а не как
- ✅ **Идемпотентный** - повторные сборки дают одинаковый результат
- ✅ **Слоистый** - каждая инструкция создает новый слой
- ✅ **Воспроизводимый** - одинаково работает везде

### Структура Dockerfile

```text
# Типичная структура Dockerfile
Базовый образ → Установка зависимостей → Копирование кода → 
Настройка окружения → Запуск приложения

FROM base_image
RUN install_dependencies
COPY source_code
WORKDIR directory
EXPOSE ports
CMD command
```

---

</details>

<details>
<summary><b>📝Основные инструкции</b></summary>

---

### FROM - базовый образ

```dockerfile
# Использование официальных образов
FROM ubuntu:20.04

# Использование минимальных образов
FROM alpine:3.14

# Использование специфичных образов
FROM python:3.9-slim

# Многостадийные сборки
FROM node:16 as builder
FROM nginx:alpine as production
```

### RUN - выполнение команд

```dockerfile
# Простая команда
RUN apt-get update

# Объединение команд для уменьшения слоев
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Создание пользователя
RUN groupadd -r app && useradd -r -g app app
```

### COPY vs ADD - копирование файлов

```dockerfile
# COPY - простое копирование файлов
COPY requirements.txt /app/
COPY . /app/

# ADD - с дополнительными возможностями
ADD https://example.com/file.tar.gz /tmp/
ADD file.tar.gz /tmp/

# Best practice: использовать COPY если не нужны фичи ADD
COPY package.json package-lock.json ./
```

### WORKDIR - рабочая директория

```dockerfile
# Установка рабочей директории
WORKDIR /app

# Все последующие команды выполняются из /app
COPY . .
RUN npm install

# Можно использовать несколько раз
WORKDIR /app/src
RUN make build
```

---

</details>

<details>
<summary><b>⚙️Инструкции конфигурации</b></summary>

---

### ENV - переменные окружения

```dockerfile
# Установка переменных окружения
ENV NODE_ENV=production
ENV APP_PORT=3000
ENV APP_HOST=0.0.0.0

# Множественные переменные
ENV PYTHON_VERSION=3.9 \
    PIP_VERSION=21.0

# Использование в других инструкциях
ENV APP_HOME=/app
WORKDIR $APP_HOME
```

### ARG - аргументы сборки

```dockerfile
# Объявление аргументов
ARG VERSION=latest
ARG USERNAME=app

# Использование аргументов
FROM ubuntu:${VERSION}
RUN useradd -m ${USERNAME}

# Передача аргументов при сборке
# docker build --build-arg VERSION=20.04 .
```

### EXPOSE - объявление портов

```dockerfile
# Объявление портов которые использует приложение
EXPOSE 80
EXPOSE 443
EXPOSE 3000

# Указание протокола
EXPOSE 80/tcp
EXPOSE 53/udp

# Фактическое пробрасывание портов делается при docker run -p
```

---

</details>

<details>
<summary><b>🚀Инструкции запуска</b></summary>

---

### CMD - команда по умолчанию

```dockerfile
# Форма shell (не рекомендуется)
CMD npm start

# Форма exec (рекомендуется)
CMD ["npm", "start"]

# Форма exec с параметрами
CMD ["python", "app.py", "--host", "0.0.0.0"]

# Может быть переопределена при docker run
```

### ENTRYPOINT - точка входа

```dockerfile
# Использование как исполняемого файла
ENTRYPOINT ["/app/start.sh"]

# Комбинация с CMD
ENTRYPOINT ["python"]
CMD ["app.py"]

# В этом случае при запуске можно изменить аргументы:
# docker run my-image app2.py
```

### Разница между CMD и ENTRYPOINT

```text
CMD - команда по умолчанию, может быть переопределена
ENTRYPOINT - основная команда, аргументы могут быть добавлены

Пример:
ENTRYPOINT ["echo"]
CMD ["Hello World"]

# docker run image → echo "Hello World"
# docker run image "Test" → echo "Test"
```

---

</details>

<details>
<summary><b>🔧Дополнительные инструкции</b></summary>

---

### USER - смена пользователя

```dockerfile
# Создание непривилегированного пользователя
RUN groupadd -r app && useradd -r -g app app

# Смена пользователя
USER app

# Все последующие команды выполняются от имени app
WORKDIR /home/app
COPY --chown=app:app . .
```

### VOLUME - объявление томов

```dockerfile
# Объявление точек монтирования
VOLUME /var/log
VOLUME /data

# Множественные тома
VOLUME ["/var/log", "/data"]

# Фактическое монтирование делается при docker run -v
```

### LABEL - метаданные

```dockerfile
# Добавление метаданных
LABEL version="1.0"
LABEL description="My application"
LABEL maintainer="dev@example.com"

# Множественные метки
LABEL org.opencontainers.image.version="1.0" \
      org.opencontainers.image.description="My app"
```

---

</details>

<details>
<summary><b>🏗️Сборка образов</b></summary>

---

### Команда docker build

```bash
# Базовая сборка
docker build .

# Сборка с тегом
docker build -t my-app:latest .

# Сборка из другого контекста
docker build -t my-app:latest ./src

# Сборка с аргументами
docker build --build-arg NODE_ENV=production -t my-app:latest .

# Сборка с указанием Dockerfile
docker build -f Dockerfile.prod -t my-app:prod .
```

### Контекст сборки

```text
# Контекст - файлы и директории передаваемые в docker build
docker build .  # Текущая директория - контекст

Важно:
• Dockerfile обычно в корне контекста
• Большой контекст = медленная сборка
• Используйте .dockerignore для исключения файлов
```

### .dockerignore файл

```text
# Пример .dockerignore
.git
.gitignore
README.md
node_modules
*.log
.env
Dockerfile
.dockerignore
```

---

</details>

<details>
<summary><b>📊Оптимизация сборки</b></summary>

---

### Кэширование слоев

```dockerfile
# Плохо: каждый COPY создает новый слой
COPY . /app
RUN npm install
RUN npm run build

# Хорошо: кэшируемые слои отдельно
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run build
```

### Многостадийные сборки

```dockerfile
# Стадия сборки
FROM node:16 as builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Стадия продакшн
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Best Practices

```text
✅Используйте .dockerignore
✅Объединяйте RUN команды
✅Копируйте package.json отдельно для кэширования
✅Используйте многостадийные сборки
✅Используйте официальные базовые образы
✅Указывайте конкретные версии тегов
✅Минимизируйте количество слоев
```

---

</details>

<details>
<summary><b>🎯Практические примеры</b></summary>

---

### Пример 1: Python приложение

```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PYTHONUNBUFFERED=1

CMD ["python", "app.py"]
```

### Пример 2: Node.js приложение

```dockerfile
FROM node:16-alpine

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --only=production

COPY . .

USER node

EXPOSE 3000

CMD ["node", "server.js"]
```

### Пример 3: Многостадийная сборка

```dockerfile
# Build stage
FROM node:16 as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage  
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

</details>

<details>
<summary><b>🎯Ключевые выводы</b></summary>

---

### Основные концепции

```text
1. 📝Dockerfile - декларативное описание образа
2. 🏗️Каждая инструкция = новый слой
3. ⚡Кэширование слоев ускоряет сборку
4. 🔧CMD vs ENTRYPOINT - разное поведение запуска
5. 🚀Многостадийные сборки уменьшают размер
```

---

</details>

