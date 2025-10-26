[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [🎯 K-07-Планирование-и-ресурсы](../../README.md#-k-07-планирование-и-ресурсы)

---

# 🏷️K-07-2-Labels-and-Selectors
>Labels и Selectors — стандартный метод группировки и фильтрации объектов Kubernetes через пары ключ-значение

---

<details>
<summary><b>🔍Что такое Labels и Selectors?</b></summary>

---

## Концепция группировки объектов

**Labels** - это описания свойств, прикрепленные к каждому объекту в формате `ключ=значение`.

**Selectors** - это условия фильтрации, которые помогают найти объекты по их меткам.

### Аналогия с классификацией

Представьте коллекцию разных существ:
- 🐕 Домашние животные (собаки, кошки)
- 🦅 Дикие птицы (орлы, вороны) 
- 🐅 Дикие животные (тигры, львы)
- 🐠 Морские обитатели (рыбы, медузы)

**Метки для классификации:**
```
тип=животное, среда=дом, цвет=коричневый
тип=птица, среда=дикая, цвет=черный
тип=животное, среда=дикая, цвет=оранжевый
тип=рыба, среда=море, цвет=синий
```

**Селекторы для фильтрации:**
- `тип=животное` → все животные
- `среда=дикая` → все дикие существа
- `тип=птица, цвет=черный` → черные птицы

---

## Зачем нужны Labels в Kubernetes?

В кластере могут быть **сотни или тысячи объектов**:
- Pods, Services, ReplicaSets, Deployments
- ConfigMaps, Secrets, PersistentVolumes
- Ingress, NetworkPolicies, ServiceAccounts

**Проблемы без меток:**
- ❌ Сложно найти нужные объекты
- ❌ Нет группировки по приложениям
- ❌ Нет фильтрации по функциональности
- ❌ Сложно управлять связанными объектами

**С метками:**
- ✅ Группировка по приложениям
- ✅ Фильтрация по функциональности
- ✅ Связывание объектов между собой
- ✅ Удобное управление

> 💡 **Аналогия:** Как теги на YouTube или категории в интернет-магазине - помогают быстро найти нужный контент.

---

</details>

<details>
<summary><b>📝Как создавать Labels?</b></summary>

---

## Структура Labels в манифесте

Labels указываются в секции `metadata.labels` любого объекта Kubernetes.

### Пример Pod с метками

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx          # Приложение
    tier: frontend      # Уровень архитектуры
    environment: prod   # Окружение
    version: "1.0"      # Версия
    team: web           # Команда
spec:
  containers:
  - name: nginx
    image: nginx:latest
```

### Правила создания Labels

**✅ Хорошие метки:**
```yaml
labels:
  app: my-app           # Короткие, понятные
  tier: frontend        # Стандартные ключи
  version: "1.2.3"      # Версии в кавычках
  environment: prod     # Окружения
```

**❌ Плохие метки:**
```yaml
labels:
  my-very-long-application-name: value  # Слишком длинные
  app_name: my-app                      # Нестандартные ключи
  version: 1.2.3                        # Числа без кавычек
  "special@key": value                  # Спецсимволы
```

---

## Стандартные ключи Labels

Kubernetes рекомендует использовать стандартные ключи:

| Ключ | Описание | Пример |
|------|----------|--------|
| `app` | Имя приложения | `nginx`, `mysql`, `redis` |
| `tier` | Уровень архитектуры | `frontend`, `backend`, `database` |
| `environment` | Окружение | `dev`, `staging`, `prod` |
| `version` | Версия приложения | `"1.0"`, `"2.1.3"` |
| `component` | Компонент системы | `api`, `worker`, `scheduler` |
| `part-of` | Часть более крупной системы | `microservice-a`, `monolith` |
| `managed-by` | Кто управляет | `helm`, `kustomize`, `operator` |

### Пример с стандартными метками

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-server
  labels:
    app: web-server
    tier: frontend
    environment: production
    version: "2.1.0"
    component: nginx
    part-of: e-commerce
    managed-by: helm
spec:
  containers:
  - name: nginx
    image: nginx:2.1.0
```

---

</details>

<details>
<summary><b>🔍Как использовать Selectors?</b></summary>

---

## Команда kubectl get с селекторами

### Базовый синтаксис

```bash
# Найти все Pod'ы с меткой app=nginx
kubectl get pods --selector app=nginx

# Короткая форма
kubectl get pods -l app=nginx

# Несколько условий (И)
kubectl get pods -l app=nginx,tier=frontend

# Один из условий (ИЛИ) - через пробел
kubectl get pods -l "app=nginx app=apache"

# Исключение условий
kubectl get pods -l "app!=nginx"
```

### Примеры селекторов

```bash
# Все Pod'ы приложения nginx
kubectl get pods -l app=nginx

# Все Pod'ы frontend уровня
kubectl get pods -l tier=frontend

# Все Pod'ы в production окружении
kubectl get pods -l environment=prod

# Pod'ы nginx И frontend уровня
kubectl get pods -l app=nginx,tier=frontend

# Pod'ы НЕ в dev окружении
kubectl get pods -l environment!=dev

# Pod'ы с версией 1.0 или 2.0
kubectl get pods -l "version in (1.0,2.0)"

# Pod'ы без метки environment
kubectl get pods -l "!environment"
```

---

## Расширенные селекторы

### Set-based селекторы

```bash
# В (in) - значение в списке
kubectl get pods -l "environment in (dev,staging)"

# Не в (notin) - значение не в списке  
kubectl get pods -l "environment notin (prod)"

# Существует (exists) - метка существует
kubectl get pods -l "version"

# Не существует (!) - метка не существует
kubectl get pods -l "!version"
```

### Комбинирование условий

```bash
# Сложные условия
kubectl get pods -l "app=nginx,environment in (dev,staging),!version"

# Это означает:
# app=nginx И environment в (dev,staging) И НЕ version
```

---

## Селекторы для разных типов объектов

```bash
# Pods
kubectl get pods -l app=nginx

# Services  
kubectl get services -l app=nginx

# Deployments
kubectl get deployments -l app=nginx

# Все объекты с меткой
kubectl get all -l app=nginx

# Конкретный namespace
kubectl get pods -n production -l environment=prod
```

---

</details>

<details>
<summary><b>🔗Связывание объектов через Labels</b></summary>

---

## Как объекты находят друг друга

Kubernetes использует Labels и Selectors для **внутренней механики** связывания объектов.

### Пример: ReplicaSet и Pods

**1. ReplicaSet создает Pod'ы с метками:**
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-replicaset
  labels:
    app: nginx           # Метки самого ReplicaSet (одинаково с Pod'ами)
    component: replicaset # Дополнительная метка ReplicaSet
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx         # Селектор для поиска Pod'ов
  template:
    metadata:
      labels:
        app: nginx       # Метки Pod'ов (создаваемых)
        tier: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:latest
```

**2. ReplicaSet находит свои Pod'ы:**
- ReplicaSet ищет Pod'ы с меткой `app=nginx`
- Управляет только теми Pod'ами, которые соответствуют селектору
- Игнорирует Pod'ы с другими метками

**3. Service находит Pod'ы для балансировки:**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx           # Ищет Pod'ы с app=nginx
  ports:
  - port: 80
    targetPort: 8080
```

---

## Схема связывания объектов

```
┌─────────────────────────────────────┐
│         ReplicaSet                  │
│  labels: app=nginx-rs              │
│  selector: app=nginx                │
└─────────────────────────────────────┘
            ↓ создает
┌─────────────────────────────────────┐
│           Pod 1                     │
│  labels: app=nginx, tier=frontend  │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│           Pod 2                     │
│  labels: app=nginx, tier=frontend  │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│           Pod 3                     │
│  labels: app=nginx, tier=frontend  │
└─────────────────────────────────────┘
            ↓ находит
┌─────────────────────────────────────┐
│           Service                   │
│  selector: app=nginx                │
└─────────────────────────────────────┘
```

---

## Важные различия в метках

### Метки ReplicaSet vs Метки Pod'ов

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-replicaset
  labels:
    app: nginx           # ← Метки САМОГО ReplicaSet (одинаково с Pod'ами)
    component: replicaset # ← Дополнительная метка ReplicaSet
    managed-by: helm     # ← Кто ищет этот ReplicaSet
spec:
  selector:
    matchLabels:
      app: nginx         # ← Ищет Pod'ы с этой меткой
  template:
    metadata:
      labels:
        app: nginx       # ← Метки СОЗДАВАЕМЫХ Pod'ов
        tier: frontend   # ← ReplicaSet ищет по этим меткам
```

**Кто использует какие метки:**
- **Верхние метки** (`app: nginx`, `component: replicaset`) - когда кто-то ищет **этот ReplicaSet**
- **Нижние метки** (`app: nginx`, `tier: frontend`) - когда **ReplicaSet ищет свои Pod'ы**

> ⚠️ **Частая ошибка:** Путают метки ReplicaSet и метки Pod'ов. Селектор должен соответствовать меткам в `template.metadata.labels`!

---

</details>

<details>
<summary><b>📋Практические примеры</b></summary>

---

## Пример 1: Создание и поиск Pod'ов

### Создаем Pod с метками

```yaml
# pod-with-labels.yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-pod
  labels:
    app: web-server
    tier: frontend
    environment: dev
    version: "1.0"
spec:
  containers:
  - name: nginx
    image: nginx:latest
```

```bash
# Применяем
kubectl apply -f pod-with-labels.yaml

# Ищем по разным критериям
kubectl get pods -l app=web-server
kubectl get pods -l tier=frontend
kubectl get pods -l environment=dev
kubectl get pods -l "app=web-server,tier=frontend"
```

---

## Пример 2: ReplicaSet с правильными метками

```yaml
# replicaset-example.yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: web-rs
  labels:
    app: web-app         # Метки ReplicaSet (одинаково с Pod'ами)
    managed-by: kubectl
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app       # Ищет Pod'ы с этой меткой
  template:
    metadata:
      labels:
        app: web-app     # Метки создаваемых Pod'ов
        tier: frontend
        environment: prod
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
```

```bash
# Применяем
kubectl apply -f replicaset-example.yaml

# Проверяем что ReplicaSet нашел свои Pod'ы
kubectl get pods -l app=web-app

# NAME           READY   STATUS    RESTARTS   AGE
# web-rs-abc123  1/1     Running   0          10s
# web-rs-def456  1/1     Running   0          10s  
# web-rs-ghi789  1/1     Running   0          10s
```

---

## Пример 3: Service с селектором

```yaml
# service-example.yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web-app         # Ищет Pod'ы с app=web-app
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
```

```bash
# Применяем
kubectl apply -f service-example.yaml

# Проверяем что Service нашел Pod'ы
kubectl get endpoints web-service

# NAME           ENDPOINTS
# web-service    10.244.1.5:80,10.244.2.3:80,10.244.3.7:80
```

---

## Пример 4: Сложные селекторы

```bash
# Все Pod'ы frontend уровня в production
kubectl get pods -l "tier=frontend,environment=prod"

# Все Pod'ы с версией 1.0 или 2.0
kubectl get pods -l "version in (1.0,2.0)"

# Все Pod'ы НЕ в dev окружении
kubectl get pods -l "environment!=dev"

# Все Pod'ы без метки version
kubectl get pods -l "!version"

# Pod'ы nginx ИЛИ apache
kubectl get pods -l "app in (nginx,apache)"
```

---

## Пример 5: Отладка связывания объектов

```bash
# Проверить метки Pod'а
kubectl get pod web-pod --show-labels

# Проверить селектор Service
kubectl get service web-service -o yaml | grep -A 5 selector

# Проверить какие Pod'ы находит Service
kubectl get pods -l app=web-app

# Проверить endpoints Service
kubectl get endpoints web-service
```

---

</details>

<details>
<summary><b>📝Annotations vs Labels</b></summary>

---

## Различия между Labels и Annotations

| Аспект | Labels | Annotations |
|--------|--------|-------------|
| **Назначение** | Группировка и выбор объектов | Информационные детали |
| **Селекторы** | ✅ Можно использовать в селекторах | ❌ Нельзя использовать в селекторах |
| **Размер** | До 63 символов (ключ и значение) | До 256KB (только значение) |
| **Использование** | Kubernetes использует для связывания | Человеки и внешние системы |

---

## Когда использовать Annotations

### Информационные детали

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-pod
  labels:
    app: web-server      # Для группировки
    tier: frontend       # Для селекторов
  annotations:
    contact: "team@company.com"           # Контактная информация
    version: "2.1.3"                      # Детальная версия
    build-info: "commit:abc123, build:456" # Информация о сборке
    monitoring: "prometheus.io/scrape=true" # Настройки мониторинга
    description: "Main web server for e-commerce" # Описание
spec:
  containers:
  - name: nginx
    image: nginx:2.1.3
```

### Интеграция с внешними системами

```yaml
metadata:
  annotations:
    # Prometheus мониторинг
    prometheus.io/scrape: "true"
    prometheus.io/port: "8080"
    prometheus.io/path: "/metrics"
    
    # Grafana дашборды
    grafana.com/dashboard: "web-app-dashboard"
    
    # CI/CD информация
    jenkins.io/build: "123"
    jenkins.io/job: "web-app-deploy"
    
    # Kubernetes события
    kubernetes.io/created-by: '{"kind":"ReplicaSet","name":"web-rs"}'
```

---

## Примеры полезных Annotations

### Техническая информация
```yaml
annotations:
  version: "1.2.3"
  build-date: "2024-01-15T10:30:00Z"
  git-commit: "abc123def456"
  docker-image: "myapp:1.2.3"
```

### Контактная информация
```yaml
annotations:
  contact: "team@company.com"
  owner: "web-team"
  slack: "#web-team"
  oncall: "oncall@company.com"
```

### Мониторинг и логирование
```yaml
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8080"
  logging-level: "info"
  log-format: "json"
```

### Документация
```yaml
annotations:
  description: "Main web application server"
  documentation: "https://docs.company.com/web-app"
  runbook: "https://runbooks.company.com/web-app"
```

---

</details>

<details>
<summary><b>📚Резюме</b></summary>

---

## Ключевые моменты

1. **Labels** - пары ключ-значение для группировки объектов
2. **Selectors** - условия для фильтрации объектов по меткам
3. **Связывание** - объекты находят друг друга через labels/selectors
4. **Annotations** - дополнительная информация, не для селекторов

## Лучшие практики

### ✅ Хорошие Labels
- Используйте стандартные ключи (`app`, `tier`, `environment`)
- Короткие, понятные значения
- Версии в кавычках
- Консистентность в команде

### ❌ Избегайте
- Слишком длинные ключи/значения
- Спецсимволы в ключах
- Нестандартные ключи без необходимости
- Путаница между метками ReplicaSet и Pod'ов

## Команды для работы

```bash
# Создать объект с метками
kubectl apply -f manifest.yaml

# Найти объекты по меткам
kubectl get pods -l app=nginx
kubectl get all -l tier=frontend

# Показать метки объекта
kubectl get pod my-pod --show-labels

# Добавить метку к существующему объекту
kubectl label pod my-pod environment=prod

# Удалить метку
kubectl label pod my-pod environment-
```

## Что дальше?

Labels и Selectors - основа для:
- **Node Selectors** - привязка Pod'ов к узлам
- **Node Affinity** - продвинутая привязка к узлам  
- **Pod Affinity** - размещение Pod'ов рядом друг с другом
- **Taints and Tolerations** - ограничение доступа к узлам

> 💡 **Вывод:** Labels и Selectors - это фундамент для управления объектами в Kubernetes. Освойте их, и остальные механизмы планирования станут понятными!

---

</details>
