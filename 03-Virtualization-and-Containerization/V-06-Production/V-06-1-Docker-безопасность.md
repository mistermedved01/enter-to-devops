[🏠 Главная](../../README.md) → [🐳 Virtualization-and-Containerization](../../README.md#-virtualization-and-containerization) → [🏭 V-06-Production](../../README.md#-v-06-production)

---

# 🐳V-06-1-Docker-безопасность
> Docker безопасность: best practices, сканирование образов, ограничение прав, сетевые политики и защита кластеров.

---

<details>
<summary><b>🎯 Уровни безопасности Docker</b></summary>

---

### Многоуровневая защита

```text
# Уровни безопасности Docker
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Host Level    │    │  Container Level│    │  Cluster Level  │
│                 │    │                 │    │                 │
│ • Secure OS     │    │ • Non-root user │    │ • Network       │
│ • Firewalls     │    │ • Read-only     │    │   policies      │
│ • Updates       │    │ • Capabilities  │    │ • Secrets       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         ↓                       ↓                       ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Runtime Protection                           │
│                (gVisor, kata-containers)                        │
└─────────────────────────────────────────────────────────────────┘
```

### Ключевые векторы атак

```text
🔓 Образы из ненадежных источников
🚪 Привилегированные контейнеры  
🌐 Открытые порты и сети
🔑 Слабые учетные данные
📝 Небезопасные volume монтирования
⚙️ Необновленное ПО
```

**Цели безопасности:**
- ✅ **Изоляция** - контейнеры не должны влиять друг на друга
- ✅ **Минимальные привилегии** - принцип наименьших прав
- ✅ **Аудит и мониторинг** - обнаружение подозрительной активности
- ✅ **Обновления** - регулярное обновление образов и хоста

---

</details>

<details>
<summary><b>🔒 Безопасность образов</b></summary>

---

### Сканирование образов на уязвимости

```bash
# Сканирование образа с Docker Scout
docker scout quickview nginx:latest

# Детальное сканирование
docker scout cves nginx:latest

# Сканирование с отчетом
docker scout recommendations nginx:latest

# Использование Trivy
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image nginx:latest

# Сканирование с фильтром по серьезности
docker scout cves --only-severity critical,high my-app:latest
```

### Best practices для Dockerfile

```dockerfile
# Использование официальных базовых образов
FROM nginx:1.23-alpine

# Непривилегированный пользователь
RUN groupadd -r app && useradd -r -g app app
USER app

# Read-only корневая файловая система
docker run --read-only -v /tmp:/tmp my-app

# Подпись образов
FROM --platform=linux/amd64 nginx@sha256:abc123...
```

### Управление зависимостями

```bash
# Анализ зависимостей образа
docker scout dependencies my-app:latest

# Проверка лицензий
docker scout licenses my-app:latest

# Сканирование на секреты в образах
docker run --rm -v $(pwd):/src ghcr.io/gitleaks/gitleaks detect /src
```

---

</details>

<details>
<summary><b>🛡️ Безопасность контейнеров</b></summary>

---

### Ограничение привилегий

```bash
# Запуск без привилегий (по умолчанию)
docker run -d nginx:alpine

# Явное указание непривилегированного режима
docker run -d --security-opt=no-new-privileges nginx:alpine

# Запрет повышения привилегий
docker run -d --security-opt=no-new-privileges:true nginx:alpine

# Отключение всех capabilities
docker run -d --cap-drop=ALL nginx:alpine
```

### AppArmor и SELinux

```bash
# Использование AppArmor профиля
docker run -d \
  --security-opt apparmor=docker-default \
  nginx:alpine

# Кастомный AppArmor профиль
docker run -d \
  --security-opt apparmor=my-profile \
  nginx:alpine

# SELinux labels
docker run -d \
  --security-opt label=type:svirt_lxc_net_t \
  nginx:alpine
```

### Read-only файловая система

```bash
# Read-only корневая ФС
docker run -d \
  --read-only \
  --tmpfs /tmp \
  nginx:alpine

# Read-only с исключениями
docker run -d \
  --read-only \
  --tmpfs /run \
  --tmpfs /tmp \
  -v /data:/data:rw \
  my-app:latest

# Запрет выполнения бинарников в томах
docker run -d \
  --security-opt noexec:/data \
  -v app-data:/data \
  my-app:latest
```

---

</details>

<details>
<summary><b>🌐 Сетевая безопасность</b></summary>

---

### Ограничение сетевого доступа

```bash
# Запуск без сети
docker run -d --network none my-app:latest

# Использование внутренних сетей
docker network create --internal private-net

# Ограничение исходящих подключений
docker run -d \
  --cap-add=NET_ADMIN \
  --sysctl net.ipv4.ip_forward=0 \
  my-app:latest

# Firewall правила
iptables -A DOCKER-USER -p tcp --dport 22 -j DROP
```

### Безопасность портов

```bash
# Проброс только на localhost
docker run -d -p 127.0.0.1:8080:80 nginx:alpine

# Использование пользовательских сетей вместо проброса портов
docker network create app-net
docker run -d --network app-net --name app my-app:latest
docker run -d --network app-net -p 80:80 nginx:alpine

# Ограничение протоколов
docker run -d -p 53:53/udp dns-server
```

### TLS и сертификаты

```bash
# Защищенный Docker Daemon
dockerd \
  --tlsverify \
  --tlscacert=ca.pem \
  --tlscert=server-cert.pem \
  --tlskey=server-key.pem \
  -H=0.0.0.0:2376

# Docker client с TLS
docker --tlsverify \
  --tlscacert=ca.pem \
  --tlscert=cert.pem \
  --tlskey=key.pem \
  -H=$HOST:2376 version
```

---

</details>

<details>
<summary><b>🔐 Безопасность Swarm кластера</b></summary>

---

### Защита manager нод

```bash
# Использование нечетного количества manager нод
docker swarm init --advertise-addr <MANAGER-IP>

# Автоматический lock кластера
docker swarm init --autolock

# Разблокировка кластера
docker swarm unlock

# Ротация unlock ключа
docker swarm unlock-key --rotate
```

### Секреты и конфиги

```bash
# Создание секретов
echo "mysecretpassword" | docker secret create db_password -

# Использование секретов в сервисах
docker service create \
  --name app \
  --secret source=db_password,target=/run/secrets/db_password \
  my-app:latest

# Конфиги без секретных данных
docker config create app_config ./config.yml
```

### Network policies

```bash
# Создание изолированных сетей
docker network create --internal database-net

# Сервисы в изолированной сети
docker service create \
  --name database \
  --network database-net \
  postgres:13

# Доступ только через proxy
docker service create \
  --name proxy \
  --network database-net \
  --network public-net \
  nginx:alpine
```

---

</details>

<details>
<summary><b>📊 Мониторинг и аудит</b></summary>

---

### Логи и аудит безопасности

```bash
# Просмотр логов Docker демона
sudo journalctl -u docker.service -f

# Аудит Docker событий
docker events --filter type=container --filter event=die

# Мониторинг системных вызовов
docker run -d \
  --security-opt seccomp=audit.json \
  my-app:latest

# Логирование в syslog
dockerd --log-driver=syslog --log-opt syslog-address=udp://loghost:514
```

### Runtime защита

```bash
# Использование Falco для runtime защиты
docker run -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /etc/falco/falco.yaml:/etc/falco/falco.yaml \
  falcosecurity/falco

# Мониторинг с Sysdig
docker run -d \
  --name sysdig-agent \
  --privileged \
  --net host \
  --pid host \
  -e ACCESS_KEY=your-key \
  -e COLLECTOR=collector.sysdig.com \
  sysdig/agent
```

### Сканирование на соответствие стандартам

```bash
# Проверка с Docker Bench Security
git clone https://github.com/docker/docker-bench-security.git
cd docker-bench-security
sudo ./docker-bench-security.sh

# Проверка с inspec
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  chef/inspec exec https://github.com/dev-sec/cis-docker-benchmark
```

---

</details>

<details>
<summary><b>🔧 Hardening практики</b></summary>

---

### Hardening Docker хоста

```bash
# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка только необходимых пакетов
sudo apt install docker-ce docker-ce-cli containerd.io

# Настройка firewall
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 2376/tcp  # Docker TLS port

# Отключение IPv6 если не используется
echo 'net.ipv6.conf.all.disable_ipv6 = 1' >> /etc/sysctl.conf
```

### Безопасная конфигурация демона

```json
// /etc/docker/daemon.json
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

### User namespaces

```bash
# Включение user namespace remapping
sudo systemctl stop docker
sudo echo 'dockremap:165536:65536' >> /etc/subuid
sudo echo 'dockremap:165536:65536' >> /etc/subgid
sudo systemctl start docker

# Проверка mapping
docker run --rm alpine cat /proc/self/uid_map
```

---

</details>

<details>
<summary><b>🚨 Инцидент-ответ</b></summary>

---

### Обнаружение инцидентов

```bash
# Поиск подозрительных контейнеров
docker ps --filter "status=running"
docker ps --filter "label=security_risk"

# Проверка изменений в контейнерах
docker diff suspicious-container

# Анализ сетевой активности
docker exec container netstat -tulpn
docker exec container ss -tulpn

# Проверка процессов
docker top container
```

### Изоляция и анализ

```bash
# Остановка подозрительного контейнера
docker stop suspicious-container

# Создание образа для анализа
docker commit suspicious-container forensic-image

# Экспорт файловой системы
docker export suspicious-container > container-fs.tar

# Анализ с помощью инструментов forensics
docker run -it --rm -v $(pwd):/evidence forensics-tool
```

### Восстановление

```bash
# Вращение секретов
docker secret rotate db-password

# Обновление compromised образов
docker pull nginx:latest
docker service update --image nginx:latest web

# Аудит прав доступа
docker node ls
docker secret ls
docker config ls
```

---

</details>

<details>
<summary><b>🎯 Ключевые выводы</b></summary>

---

### Security Checklist

```text
✅ Сканируйте образы на уязвимости перед использованием
✅ Используйте непривилегированных пользователей в контейнерах
✅ Ограничивайте capabilities и привилегии
✅ Используйте read-only файловые системы где возможно
✅ Настройте сетевую изоляцию между сервисами
✅ Регулярно обновляйте образы и базовую ОС
✅ Используйте секреты вместо переменных окружения
✅ Включите логирование и мониторинг
✅ Проводите регулярные аудиты безопасности
```

### Tools для безопасности Docker

```text
🔍 Сканирование образов: Docker Scout, Trivy, Clair
🛡️ Runtime защита: Falco, Sysdig, AppArmor, SELinux
📊 Аудит: Docker Bench Security, CIS benchmarks  
🔒 Secrets: Docker Secrets, HashiCorp Vault
🌐 Сеть: Calico, Cilium для network policies
```

### Что дальше

```text
📚 Следующая тема: Мониторинг и логи - наблюдение за приложениями
🎯 Цель: Создавать безопасные production-окружения
🔚 Завершение курса: Итоговый проект и best practices
```

---

</details>
