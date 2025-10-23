[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [📚 K-01-Архитектура-Kubernetes](../../README.md#-k-01-архитектура-kubernetes)

---

# ☸️K-01-1-Architecture-Kubernetes
>master-компоненты, kubelet, API-server, scheduler, etcd, kubectl flow

📗**Материалы:**
- [Kubernetes — Простым Языком на Понятном Примере [YouTube.com]](https://www.youtube.com/watch?v=TwyhnBDOHPw)

---

<details>
<summary><b>🏗️Общая архитектура</b></summary>

---

Архитектура Kubernetes проще, чем кажется - вы **не взаимодействуете напрямую с нодами**. Вся работа осуществляется через:

- **Dashboard** - веб-панель управления
- **API** - программный интерфейс  
- **kubectl** - инструмент командной строки

<img src="../img/k8s_cluster_scheme.png" alt="k8s_cluster_scheme" width="700">

---

## 🎯Control Plane (Master Node) - управляющие узлы

Запускают компоненты управления:

- **kube-apiserver** - API-сервер (единая точка входа)
- **kube-scheduler** - планировщик (распределение Pod'ов по нодам)
- **kube-controller-manager** - менеджер контроллеров (управление состоянием)
- **etcd** - распределенное key-value хранилище состояния кластера
- **cloud-controller-manager** - интеграция с облачными провайдерами (опционально)

---

## ⚙️Worker Nodes - рабочие узлы

Запускают приложения и дополнительные компоненты:

- **kubelet** - агент, выполняющий инструкции от Control Plane
- **kube-proxy** - сетевой прокси (маршрутизация трафика между сервисами)
- **Container Runtime** - docker, containerd, CRI-O (запуск контейнеров)
- **Плагины** - сетевое взаимодействие, мониторинг, логирование

---

</details>

<details>
<summary><b>🧱Основные ресурсы</b></summary>

---

Ресурсы Kubernetes - это **строительные блоки** для запуска приложений в кластере.

### 🎯Основные объекты управления

#### Pods
- **Минимальная сущность** для развертывания
- Один или несколько контейнеров
- Общие сеть и хранилище

#### ReplicaSets
- **Гарантирует количество** запущенных Pod'ов
- Замена Replication Controller
- Самовосстановление при сбоях

#### Deployments
- **Декларативные обновления** Pod'ов и ReplicaSets
- История изменений и откат
- Рекомендуемый способ управления приложениями

#### StatefulSets
- Для приложений **с сохранением состояния**
- Устойчивые идентификаторы и хранилище
- Базы данных, кэши

#### DaemonSet
- **По одному Pod'у на ноде**
- Агенты мониторинга, логгирования
- Обязательные сервисы на каждой ноде

#### Jobs/CronJob
- **Задачи с завершением**
- Одноразовые или периодические задания
- Миграции БД, обработка данных

---

### 🏷️Организация и идентификация

#### Labels and Selectors
```yaml
metadata:
  labels:
    app: frontend
    tier: web
```

- **Пары ключ/значение** для идентификации объектов
- **Селекторы** для поиска и группировки

#### Namespaces
```bash
kubectl create namespace development
kubectl get pods -n development
```

- **Виртуальные кластеры** в физическом кластере
- Изоляция сред (dev/staging/prod)
- Разделение доступа между командами

---

### 🌐Сеть и конфигурация

#### Services
- **Абстракция доступа** к набору Pod'ов
- Балансировка нагрузки
- Постоянный IP и DNS-имя

#### Annotations
```yaml
metadata:
  annotations:
    description: "Production database"
    version: "2.1"
```

- **Произвольные метаданные**
- Информация для инструментов
- Не для идентификации

#### ConfigMaps
- **Внешняя конфигурация** приложений
- Отделение конфига от образов
- Переопределение параметров

#### Secrets
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  password: cGFzc3dvcmQ=
```

- **Хранение конфиденциальной информации**
- Пароли, токены, SSH-ключи
- Безопасное распределение секретов

---

</details>

<details>
<summary><b>🛠️Взаимодействие с кластером</b></summary>

---

### Основные команды kubectl

```bash
# Просмотр ресурсов
kubectl get pods
kubectl get deployments
kubectl get services

# Создание ресурсов
kubectl create -f deployment.yaml
kubectl apply -f configmap.yaml

# Управление приложениями
kubectl scale deployment frontend --replicas=5
kubectl rollout status deployment/backend

# Отладка
kubectl describe pod frontend-pod
kubectl logs frontend-pod
kubectl exec -it frontend-pod -- /bin/bash
```

---

</details>

<details>
<summary><b>✅Декларативный подход</b></summary>

---

Вместо последовательности команд описываем **желаемое состояние**:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
        ports:
        - containerPort: 80
```

Kubernetes сам приведет текущее состояние к желаемому.

---

</details>

<details>
<summary><b>🚀Архитектура Kubernetes: космическая аналогия</b></summary>

---

<img src="img/k8s_space_station.jpg" alt="" width="700">

Представь, что Kubernetes — это галактическая станция, управляющая флотом контейнеровозов.

Есть два типа кораблей:

- **Контейнеровозы (worker nodes)** — рабочие корабли, которые перевозят контейнеры с приложениями.

- **Командная станция (master node)** — управляет всем флотом: планирует маршруты, следит за состоянием кораблей и координирует работу.

---

#### Компоненты Control Plane (Master)

- **ETCD** — NoSQL база данных, где хранится всё состояние кластера: какие контейнеры где, какие ноды активны и т.д.  
- **Kube-apiserver** — центральная диспетчерская. Через него общаются все компоненты и пользователи.  
- **Scheduler** — решает, на какую ноду отправить новый контейнер, учитывая ресурсы и политики (`taints`, `affinity` и др.) 
- **Controller Manager** — объединяет разные контроллеры, которые следят за стабильностью кластера:  
  - `node-controller` следит за состоянием нод,  
  - `replication-controller` раньше поддерживал нужное число Pod’ов,  
    но сейчас **заменён на ReplicaSet и Deployment**, которые делают то же самое, но гибче и современнее.  

---

#### Компоненты Worker Node

- **Kubelet** — капитан корабля. Получает приказы от станции, запускает контейнеры и отчитывается о состоянии.  
- **Kube-proxy** — обеспечивает связь между контейнерами на разных нодах, управляя сетевыми правилами.  
- **Container Runtime** — движок, который запускает контейнеры (Docker, ContainerD, CRI-O).  

---

### 🎯 Соответствие терминов

| Космическая аналогия | Kubernetes компонент | Роль |
|---------------------|---------------------|------|
| Командная станция | Control Plane | Управление флотом |
| Контейнеровоз | Worker Node | Выполнение задач |
| Капитан корабля | Kubelet | Управление контейнерами |
| Центральная диспетчерская | kube-apiserver | Координация |
| Штурман | kube-scheduler | Планирование маршрутов |
| Архив станции | etcd | Хранение состояния |
| Офицер связи | kube-proxy | Сетевая коммуникация |

---

### 🔄 Процесс запуска приложения
Пользователь → kubectl apply → API Server → etcd
↓
Scheduler → Назначение ноды → API Server → etcd
↓
Kubelet (на ноде) → Container Runtime → Запуск Pod

text

---

</details>

<details>
<summary><b>💡Ключевые принципы для запоминания</b></summary>

---

1. **✅Декларативность** - описываем "что", а не "как"
2. **✅Самовосстановление** - автоматическое поддержание состояния  
3. **✅Масштабируемость** - легко увеличить/уменьшить нагрузку
4. **✅Переносимость** - одинаково работает везде
5. **✅Модульность** - компоненты независимы и заменяемы

---

</details>

<details>
<summary><b>🎯Что важно понять новичку</b></summary>

---

- **🔹Pods** - базовые "кирпичики" приложений
- **🚀Deployments** - основной способ управления
- **🌐Services** - как приложения общаются между собой  
- **📁Namespaces** - организация и изоляция
- **⚡kubectl** - основной инструмент управления

> 💡**Совет:** Не пытайтесь запомнить все сразу! Начинайте с Pods → Deployments → Services, остальное придет с практикой.

> 🎯 **Практический совет:** При отладке проблем всегда начинайте с:
```bash
kubectl get nodes          # Проверить состояние нод
kubectl get pods -A        # Общий обзор всех Pod'ов
kubectl describe pod <pod-name>  # Детальная информация о Pod'е
```

</details>

---