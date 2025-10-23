[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [⚙️ K-03-Worker-компоненты](../../README.md#-k-03-worker-компоненты)

---

# ⚙️K-03-2-Worker-Component-Kube-Proxy
>kube-proxy - сетевой прокси, обеспечивает коммуникацию между сервисами и балансировку нагрузки

---

<details>
<summary><b>🎯Роль kube-proxy в кластере</b></summary>

---

## Проблема сетевой коммуникации

**Без kube-proxy:**
- ✅ Pod'ы могут общаться через POD network
- ❌ IP-адреса Pod'ов нестабильны
- ❌ Нет абстракции для доступа к группам Pod'ов

**С kube-proxy:**
- ✅ Стабильные Service IP-адреса
- ✅ Балансировка нагрузки между Pod'ами
- ✅ DNS-имена для сервисов

## Аналогия с сетевым диспетчером

```
# kube-proxy = сетевой диспетчер станции
# Отслеживает службы и создает правила маршрутизации

Service (виртуальный) → kube-proxy → Фактические Pod'ы
      ↓                     ↓              ↓
   db-service          Правила         [pod-db-1]
   IP: 10.96.0.12     маршрутизации    [pod-db-2]
```

---

</details>

<details>
<summary><b>🌐Сетевые концепции Kubernetes</b></summary>

---

## POD Network

```
# Виртуальная сеть, охватывающая все узлы кластера
Node1: [Pod A: 10.244.1.2] ↔ [Pod B: 10.244.2.3] :Node2
     ↓          POD Network           ↓
  eth0: 192.168.1.10             eth0: 192.168.1.11
```

**Характеристики POD Network:**
- 🔹 Виртуальная overlay-сеть
- 🔹 Все Pod'ы могут общаться друг с другом
- 🔹 Разные реализации (Flannel, Calico, WeaveNet)

## Services - виртуальные объекты

```
# Service НЕ является контейнером или Pod'ом
# Это набор правил в памяти нод

apiVersion: v1
kind: Service
metadata:
  name: db-service
spec:
  selector:
    app: database
  ports:
    - protocol: TCP
      port: 5432
      targetPort: 5432
```

**Важно:** Service не имеет сетевых интерфейсов, это абстракция!

---

</details>

<details>
<summary><b>🔧Как работает kube-proxy</b></summary>

---

## Мониторинг сервисов

```
# kube-proxy отслеживает создание/удаление сервисов
kube-proxy → kube-apiserver → События о сервисах
     ↓              ↓               ↓
 Обновляет     Получает       Service created
 правила     информацию      Service deleted
```

## Создание правил IPTABLES

```
# Пример правила для сервиса
# Трафик на Service IP перенаправляется на Pod IP

Service: 10.106.0.12:5432 → iptables → Pod: 10.244.0.3:5432
                          → Pod: 10.244.0.4:5432
                          → Pod: 10.244.0.5:5432
```

## Процесс запроса

```
# Весь процесс от запроса до ответа
Web Pod → db-service:5432 → iptables → Database Pod
   ↓           ↓               ↓           ↓
10.244.1.5  10.106.0.12    Правила    10.244.0.3
                          маршрутизации
```

---

</details>

<details>
<summary><b>🛠️Режимы работы kube-proxy</b></summary>

---

## userspace (устаревший)

```
# kube-proxy сам проксирует трафик
kube-proxy --proxy-mode=userspace
```

**Характеристики:**
- 🔹 Медленный (трафик через userspace)
- 🔹 Устаревший режим
- 🔹 Не рекомендуется

## iptables (рекомендуемый)

```
# Использует iptables для маршрутизации
kube-proxy --proxy-mode=iptables
```

**Характеристики:**
- 🔹 Быстрый (трафик в kernel space)
- 🔹 Стандартный режим
- 🔹 Хорошая производительность

## ipvs (продвинутый)

```
# Использует IP Virtual Server
kube-proxy --proxy-mode=ipvs
```

**Характеристики:**
- 🔹 Лучшая производительность
- 🔹 Поддержка различных алгоритмов балансировки
- 🔹 Рекомендуется для больших кластеров

---

</details>

<details>
<summary><b>⚙️Установка и настройка</b></summary>

---

## Ручная установка

```
# Скачать бинарник kube-proxy
wget https://github.com/kubernetes/kubernetes/releases/download/v1.28.0/kubernetes-server-linux-amd64.tar.gz

# Распаковать и установить
tar -xzf kubernetes-server-linux-amd64.tar.gz
cd kubernetes/server/bin
cp kube-proxy /usr/local/bin/
```

## Конфигурация kube-proxy

```
kube-proxy \
  --kubeconfig=/etc/kubernetes/kube-proxy.conf \
  --cluster-cidr=10.244.0.0/16 \
  --proxy-mode=iptables \
  --conntrack-max-per-core=0
```

## Параметры конфигурации

| Параметр | Назначение |
|----------|------------|
| `--kubeconfig` | Конфиг для доступа к API |
| `--cluster-cidr` | CIDR Pod network |
| `--proxy-mode` | Режим работы (iptables/ipvs) |
| `--conntrack-max-per-core` | Лимиты соединений |

---

</details>

<details>
<summary><b>🔍kube-proxy в kubeadm кластере</b></summary>

---

## DaemonSet развертывание

```
# kubeadm разворачивает kube-proxy как DaemonSet
kubectl get daemonset -n kube-system kube-proxy

# Посмотреть Pod'ы kube-proxy на всех нодах
kubectl get pods -n kube-system -l k8s-app=kube-proxy
```

## Проверка конфигурации

```
# Посмотреть конфиг kube-proxy
kubectl get configmap -n kube-system kube-proxy -o yaml

# Проверить логи kube-proxy
kubectl logs -n kube-system -l k8s-app=kube-proxy
```

## Расположение в kubeadm

```
# Конфигурационные файлы
/etc/kubernetes/kube-proxy.conf
/var/lib/kube-proxy/config.conf

# DaemonSet манифест
kubectl get daemonset kube-proxy -n kube-system -o yaml
```

---

</details>

<details>
<summary><b>🎯Ключевые выводы</b></summary>

---

## Основные принципы

1. **📌 Сетевой прокси** - обеспечивает работу Service abstraction
2. **📌 На каждой ноде** - работает как DaemonSet
3. **📌 Правила маршрутизации** - использует iptables/ipvs
4. **📌 Балансировка нагрузки** - распределяет трафик между Pod'ами
5. **📌 Динамическое обновление** - отслеживает изменения сервисов

## Архитектура взаимодействия

```
Service → kube-proxy → Сетевые правила → Pod'ы бэкенда
   ↓           ↓              ↓              ↓
Виртуальный  Создает      iptables/ipvs   Фактические
IP: 10.96.x.x правила     правила         контейнеры
```

---

</details>

---