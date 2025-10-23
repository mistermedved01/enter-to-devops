[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [⚙️ K-03-Worker-компоненты](../../README.md#-k-03-worker-компоненты)

---

# ⚙️K-03-1-Worker-Component-Kubelet
>kubelet - агент рабочих узлов, управляет контейнерами и выполняет инструкции от Control Plane

---

<details>
<summary><b>🎯Роль kubelet в кластере</b></summary>

---

## Аналогия с капитаном корабля

**kubelet** - это капитан рабочей ноды, который:

- ✅ **Управляет** всеми активностями на своей ноде
- ✅ **Исполняет** инструкции от планировщика
- ✅ **Мониторит** состояние Pod'ов и контейнеров
- ✅ **Отчитывается** о состоянии контрольной станции

## Ключевые обязанности

```
# Функции kubelet на рабочей ноде
1. Регистрация ноды в кластере
2. Получение инструкций от kube-apiserver
3. Запуск и остановка контейнеров
4. Мониторинг состояния Pod'ов
5. Отправка отчетов о состоянии
```

---

</details>

<details>
<summary><b>🔧Основные функции kubelet</b></summary>

---

## 1. Регистрация ноды в кластере

```
# Kubelet регистрирует ноду при запуске
kubelet --kubeconfig=/etc/kubernetes/kubelet.conf \
        --config=/var/lib/kubelet/config.yaml
```

**Процесс регистрации:**
- 📝 Предоставляет информацию о ноде (CPU, память, ОС)
- 🔐 Аутентифицируется в кластере
- 🏷️ Добавляет метки и аннотации

## 2. Исполнение инструкций по Pod'ам

```
# Получает манифест Pod от kube-apiserver
# Взаимодействует с container runtime
kubelet → container runtime → Запуск контейнера
```

**Действия:**
- 📥 Скачивание образов контейнеров
- 🚀 Запуск контейнеров с указанными параметрами
- 🔄 Управление жизненным циклом Pod'ов

## 3. Мониторинг и отчетность

```
# Постоянный мониторинг состояния
kubelet → kube-apiserver: "Pod healthy"
kubelet → kube-apiserver: "Container restarted"
kubelet → kube-apiserver: "Node resources"
```

**Мониторинг:**
- ❤️ Health checks (liveness/readiness probes)
- 📊 Использование ресурсов
- ⚠️ Состояние контейнеров

---

</details>

<details>
<summary><b>🛠️Установка и настройка</b></summary>

---

## Установка kubelet

```
# Скачать бинарник kubelet
wget https://github.com/kubernetes/kubernetes/releases/download/v1.28.0/kubernetes-server-linux-amd64.tar.gz

# Распаковать и установить
tar -xzf kubernetes-server-linux-amd64.tar.gz
cd kubernetes/server/bin
cp kubelet /usr/local/bin/
```

## Важное отличие от других компонентов

```
# kubelet НЕ устанавливается автоматически kubeadm
# Требуется РУЧНАЯ установка на каждую рабочую ноду

# Control Plane компоненты → kubeadm устанавливает
# kubelet → Администратор устанавливает вручную
```

## Базовая конфигурация службы

```
# Systemd service файл (/etc/systemd/system/kubelet.service)
[Unit]
Description=Kubernetes Kubelet
After=docker.service

[Service]
ExecStart=/usr/local/bin/kubelet \
  --config=/var/lib/kubelet/config.yaml \
  --kubeconfig=/etc/kubernetes/kubelet.conf \
  --container-runtime=remote \
  --container-runtime-endpoint=unix:///run/containerd/containerd.sock

[Install]
WantedBy=multi-user.target
```

---

</details>

<details>
<summary><b>⚙️Ключевые параметры конфигурации</b></summary>

---

## Основные параметры запуска

```
kubelet \
  --kubeconfig=/etc/kubernetes/kubelet.conf \
  --config=/var/lib/kubelet/config.yaml \
  --container-runtime=remote \
  --container-runtime-endpoint=unix:///run/containerd/containerd.sock \
  --node-labels=env=production,disk=ssd \
  --register-node=true \
  --v=2
```

## Важные опции

| Параметр | Назначение |
|----------|------------|
| `--kubeconfig` | Конфиг для доступа к API кластера |
| `--config` | Основной конфигурационный файл |
| `--container-runtime` | Тип рантайма (remote, docker) |
| `--container-runtime-endpoint` | Сокет для общения с рантаймом |
| `--node-labels` | Метки ноды для планировщика |
| `--register-node` | Авторегистрация в кластере |
| `--v` | Уровень логирования |

---

</details>

<details>
<summary><b>🔍Просмотр состояния kubelet</b></summary>

---

## Проверка работающего процесса

```
# Посмотреть запущенный процесс kubelet
ps aux | grep kubelet

# Детальный просмотр параметров
ps -ef | grep kubelet | grep -v grep

# Или с помощью systemctl
systemctl status kubelet
```

## Просмотр логов

```
# Логи kubelet
journalctl -u kubelet -f

# Или через systemd
systemctl status kubelet -l
```

## Проверка состояния ноды

```
# Из кластера посмотреть ноду
kubectl get nodes

# Детальная информация о ноде
kubectl describe node <node-name>

# Проверить готовность ноды
kubectl get nodes -o wide
```

---

</details>

<details>
<summary><b>📋Конфигурационные файлы</b></summary>

---

## Расположение файлов

```
# Основные конфигурационные файлы
/var/lib/kubelet/config.yaml          # Основной конфиг
/etc/kubernetes/kubelet.conf          # Kubeconfig для API
/etc/systemd/system/kubelet.service   # Systemd service
/var/lib/kubelet/kubeadm-flags.env    # Флаги kubeadm (если используется)
```

## Пример config.yaml

```
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
address: 0.0.0.0
port: 10250
clusterDomain: cluster.local
clusterDNS:
  - 10.96.0.10
```

---

</details>

<details>
<summary><b>🔧Взаимодействие с другими компонентами</b></summary>

---

## Архитектура взаимодействия

```
kube-apiserver → kubelet → container runtime → контейнеры
      ↓              ↓             ↓              ↓
   Инструкции    Исполнение    Запуск/остановка  Рабочие
   по Pod'ам                 контейнеров        нагрузки
```

## Container Runtime Interface (CRI)

```
# Kubelet общается с рантаймом через CRI
kubelet --container-runtime=remote \
        --container-runtime-endpoint=unix:///run/containerd/containerd.sock
```

**Поддерживаемые рантаймы:**
- 🐳 Docker (устаревший)
- 🔄 Containerd (рекомендуемый)
- ⚡ CRI-O

---

</details>

<details>
<summary><b>🎯Ключевые выводы</b></summary>

---

## Основные принципы kubelet

1. **📌 Агент рабочих узлов** - единственный обязательный компонент на worker nodes
2. **📌 Исполнитель инструкций** - получает и выполняет команды от control plane
3. **📌 Мониторинг и отчетность** - отслеживает состояние и отчитывается
4. **📌 Ручная установка** - требует отдельной установки на каждую ноду
5. **📌 Критический компонент** - без kubelet нода не может работать в кластере

## Жизненный цикл Pod на ноде

```
Получение манифеста → Создание Pod → Мониторинг → Отчетность
       ↓                 ↓            ↓           ↓
   kube-apiserver     Запуск       Health     kube-apiserver
                    контейнеров    checks
```

---

</details>

---