[🏠 Главная](../../README.md) → [🐳 Virtualization-and-Containerization](../../README.md#-virtualization-and-containerization) → [🚀 V-01-Docker-Basics](../../README.md#-v-01-docker-basics)

---

# 🐳V-01-0-Установка-Docker
>Установка Docker на различные операционные системы: Linux, Windows, macOS. Настройка окружения и проверка работоспособности.

---

<details>
<summary><b>🎯Что такое Docker?</b></summary>

---

**Docker** - это платформа для разработки, доставки и запуска приложений в контейнерах:

- ✅ **Изоляция** - приложения работают в изолированных средах
- ✅ **Переносимость** - одинаково работает везде
- ✅ **Эффективность** - меньше ресурсов чем у виртуальных машин
- ✅ **Скорость** - быстрый запуск и развертывание

```text
# Контейнеры vs Виртуальные машины

Виртуальные машины:          Контейнеры:
┌─────────────────┐         ┌─────────────────┐
│    App A        │         │    App A        │
├─────────────────┤         ├─────────────────┤
│   Библиотеки    │         │   Библиотеки    │
├─────────────────┤         ├─────────────────┤
│   Guest OS      │         │  Docker Engine  │
├─────────────────┤         ├─────────────────┤
│   Hypervisor    │         │   Host OS       │
├─────────────────┤         ├─────────────────┤
│   Hardware      │         │   Hardware      │
└─────────────────┘         └─────────────────┘
```

---

</details>

<details>
<summary><b>💻Установка на Linux</b></summary>

---

## Ubuntu/Debian

```bash
# Обновление пакетов
sudo apt update
sudo apt upgrade -y

# Установка зависимостей
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release

# Добавление GPG ключа Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Добавление репозитория
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Установка Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io

# Проверка установки
sudo docker --version
```

## CentOS/RHEL

```bash
# Установка yum-utils
sudo yum install -y yum-utils

# Добавление репозитория Docker
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Установка Docker
sudo yum install docker-ce docker-ce-cli containerd.io

# Запуск и включение Docker
sudo systemctl start docker
sudo systemctl enable docker

# Проверка
docker --version
```

---

</details>

<details>
<summary><b>🪟Установка на Windows</b></summary>

---

### Windows 10/11 с WSL2

```bash
# 1. Включение WSL2
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 2. Скачать и установить ядро Linux:
# https://aka.ms/wsl2kernel

# 3. Установить Docker Desktop:
# https://docker.com/products/docker-desktop
```

### Проверка установки

```bash
# Открыть PowerShell или WSL
docker --version
docker-compose --version

# Запустить тестовый контейнер
docker run hello-world
```

---

</details>

<details>
<summary><b>🍎Установка на macOS</b></summary>

---

### Docker Desktop для Mac

```bash
# 1. Скачать Docker Desktop:
# https://docker.com/products/docker-desktop

# 2. Установить двойным кликом на .dmg файл

# 3. Перетащить Docker в папку Applications

# 4. Запустить Docker из Launchpad
```

### Проверка установки

```bash
# Открыть Terminal
docker --version
docker-compose --version

# Тестовый запуск
docker run hello-world
```

---

</details>

<details>
<summary><b>🔧Настройка после установки</b></summary>

---

## Настройка прав пользователя (Linux)

```bash
# Добавление пользователя в группу docker
sudo usermod -aG docker $USER

# Перелогин или выполнить:
newgrp docker

# Проверка прав
docker ps
```

## Настройка Docker Daemon

```bash
# Создание конфигурационного файла
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF

# Перезапуск Docker
sudo systemctl restart docker
```

---

</details>

<details>
<summary><b>🚀Проверка работоспособности</b></summary>

---

### Базовые команды проверки

```bash
# Проверка версии
docker --version
docker-compose --version
docker version

# Проверка системы
docker system info

# Запуск тестового контейнера
docker run hello-world

# Просмотр образов
docker images

# Просмотр контейнеров
docker ps -a
```

## Тестовый сценарий

```bash
# Запуск Nginx контейнера
docker run -d -p 80:80 --name web nginx

# Проверка в браузере
http://localhost

# Остановка и удаление
docker stop web
docker rm web
```

---

</details>

<details>
<summary><b>🔧Устранение проблем</b></summary>

---

### Распространенные проблемы

```bash
# Проблема: "Cannot connect to the Docker daemon"
sudo systemctl status docker    # Проверить статус
sudo systemctl start docker     # Запустить демон

# Проблема: "Permission denied"
sudo usermod -aG docker $USER  # Добавить в группу
newgrp docker                  # Обновить группы

# Проблема: порт уже занят
docker ps                      # Найти контейнер использующий порт
docker stop <container-id>     # Остановить контейнер
```

### Полезные команды диагностики

```bash
# Логи Docker
sudo journalctl -u docker.service

# Дисковое пространство
docker system df

# Очистка системы
docker system prune -a
```

---

</details>

<details>
<summary><b>🎯Ключевые выводы</b></summary>

---

## Что мы узнали

1. **🐳 Docker установлен** на вашей системе
2. **🔧 Настроены права** для работы без sudo
3. **🚀 Проверена работоспособность** через тестовые контейнеры
4. **🛠️ Изучены основные команды** для управления Docker
5. **🔍 Знаем как диагностировать** проблемы

## Следующие шаги

```text
✅ Изучить базовые команды Docker
✅ Понять разницу между образами и контейнерами  
✅ Научиться создавать Dockerfile
✅ Освоить Docker Compose
✅ Изучить Docker Networking
```

---

</details>
