[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [🌱 K-04-Ресурсы-Kubernetes](../../README.md#-k-04-ресурсы-kubernetes)

# 📚K-04-2-Resource-Kubernetes-YAML
>YAML-манифесты Kubernetes: структура, обязательные поля, создание и настройка ресурсов через декларативный подход

---

<details>
<summary><b>🎯Структура YAML-манифеста Kubernetes</b></summary>

---

## Обязательные верхнеуровневые поля

Каждый манифест Kubernetes должен содержать **4 обязательных поля**:

```
apiVersion: v1          # Версия API Kubernetes
kind: Pod               # Тип создаваемого объекта
metadata:               # Метаданные объекта
  name: myapp-pod       # Имя объекта
  labels:               # Метки для идентификации
    app: myapp
spec:                   # Спецификация объекта
  containers:           # Список контейнеров
  - name: nginx-container
    image: nginx:latest
```

**Все 4 поля являются "братьями"** - находятся на одном уровне вложенности.

---

</details>

<details>
<summary><b>📝Детальный разбор полей</b></summary>

---

## 1. apiVersion - версия API

```
# Доступные значения apiVersion для разных объектов
apiVersion: v1                       # Для Pod, Service, ConfigMap
apiVersion: apps/v1                  # Для Deployment, ReplicaSet
apiVersion: batch/v1                 # Для Job, CronJob
apiVersion: networking.k8s.io/v1     # Для Ingress
```

## 2. kind - тип объекта

```
# Возможные значения kind
kind: Pod
kind: Service
kind: Deployment
kind: ReplicaSet
kind: ConfigMap
kind: Secret
```

## 3. metadata - метаданные объекта

```
metadata:
  name: myapp-pod                    # Обязательное поле
  labels:                            # Словарь меток
    app: myapp
    tier: frontend
    environment: production
  annotations:                       # Дополнительные метаданные
    description: "Main application pod"
```

## 4. spec - спецификация объекта

```
spec:
  containers:                        # Список контейнеров
  - name: nginx-container
    image: nginx:1.20
    ports:
    - containerPort: 80
```

---

</details>

<details>
<summary><b>🔧Правила форматирования YAML</b></summary>

---

## Правильные отступы

```
# ✅ ПРАВИЛЬНО - одинаковые отступы для "братьев"
metadata:
  name: myapp-pod       # ← Одинаковый отступ
  labels:               # ← Одинаковый отступ
    app: myapp          # ← Больший отступ (дочерний элемент)
```

```
# ❌ НЕПРАВИЛЬНО - разные отступы для "братьев"
metadata:
  name: myapp-pod
      labels:           # ← Слишком большой отступ
        app: myapp
```

```
# ❌ НЕПРАВИЛЬНО - одинаковые отступы для родителя и детей
metadata:
name: myapp-pod         # ← Должен быть отступ!
labels:
app: myapp              # ← Должен быть отступ!
```

## Структура данных в YAML

```
# Dictionary (словарь) - пары ключ: значение
metadata:
  name: myapp-pod
  labels:
    app: myapp

# List (список) - элементы с дефисами
containers:
- name: container1
  image: nginx
- name: container2      # ← Второй элемент списка
  image: redis
```

---

</details>

<details>
<summary><b>🏷️Метаданные и labels</b></summary>

---

## Назначение меток (labels)

```
# Метки для группировки и фильтрации Pod'ов
metadata:
  labels:
    app: frontend       # Тип приложения
    tier: web           # Уровень в архитектуре
    environment: prod   # Окружение
    version: "1.2"      # Версия приложения
```

## Практическое использование меток

```
# Фильтрация Pod'ов по меткам
kubectl get pods -l app=frontend
kubectl get pods -l tier=web,environment=prod
kubectl get pods -l 'version in (1.2, 1.3)'
```

**Важно:** В `metadata` можно использовать только предопределенные Kubernetes поля, но в `labels` можно добавлять любые пары ключ-значение.

---

</details>

<details>
<summary><b>🐳Спецификация контейнеров</b></summary>

---

## Базовая конфигурация контейнера

```
spec:
  containers:
  - name: nginx-container        # Имя контейнера
    image: nginx:1.20            # Docker образ
    imagePullPolicy: IfNotPresent # Политика загрузки образа
    ports:
    - containerPort: 80          # Порт контейнера
    env:                         # Переменные окружения
    - name: ENV_VAR
      value: "production"
```

## Расширенная конфигурация

```
spec:
  containers:
  - name: app-container
    image: myapp:latest
    command: ["npm", "start"]    # Переопределение команды
    args: ["--port=3000"]        # Аргументы команды
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

---

</details>

<details>
<summary><b>🛠️Практические примеры</b></summary>

---

## Пример 1: Простой Pod с nginx

```
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
    role: webserver
spec:
  containers:
  - name: nginx-container
    image: nginx:1.20
    ports:
    - containerPort: 80
```

## Пример 2: Pod с несколькими контейнерами

```
apiVersion: v1
kind: Pod
metadata:
  name: web-app
  labels:
    app: webapp
    monitoring: enabled
spec:
  containers:
  - name: web-server
    image: nginx:1.20
    ports:
    - containerPort: 80
  - name: log-agent
    image: fluentd:latest
    env:
    - name: FLUENTD_CONF
      value: "fluent.conf"
```

## Пример 3: Pod с переменными окружения

```
apiVersion: v1
kind: Pod
metadata:
  name: configurable-app
spec:
  containers:
  - name: app
    image: myapp:latest
    env:
    - name: DATABASE_URL
      value: "postgresql://localhost:5432/mydb"
    - name: DEBUG
      value: "true"
    - name: MAX_CONNECTIONS
      value: "100"
```

---

</details>

<details>
<summary><b>🚀Создание и управление Pod'ами</b></summary>

---

## Создание Pod из YAML-файла

```
# Создание Pod
kubectl create -f pod-definition.yml

# Или с применением (более современный способ)
kubectl apply -f pod-definition.yml

# Просмотр созданных Pod'ов
kubectl get pods

# Детальная информация о Pod
kubectl describe pod nginx-pod

# Удаление Pod
kubectl delete -f pod-definition.yml
```

## Проверка синтаксиса YAML

```
# Проверить синтаксис без применения
kubectl apply -f pod-definition.yml --dry-run=client

# Проверить валидность манифеста
kubectl validate -f pod-definition.yml
```

---

</details>

---

## Резюме

✅ **Kubernetes YAML** — декларативный способ описания объектов Kubernetes

✅ **Обязательная структура манифеста:**
1. `apiVersion` → Версия API (v1, apps/v1, batch/v1)
2. `kind` → Тип объекта (Pod, Deployment, Service)
3. `metadata` → Метаданные (name, labels, annotations)
4. `spec` → Спецификация (контейнеры, volumes, и т.д.)

✅ **Best Practices:**
- Всегда используйте 4 обязательных поля
- Соблюдайте правильные отступы в YAML
- Используйте метки для организации объектов
- Проверяйте синтаксис перед применением
- Храните манифесты в системе контроля версий

✅ **Распространенные ошибки:**
- Отсутствие обязательных полей
- Неправильные отступы
- Использование неподдерживаемых полей в metadata
- Опечатки в именах полей (containers vs container)
- Неверный apiVersion для kind

> 💡 **Совет:** Используйте `kubectl explain pod` для просмотра документации по структуре Pod'а.

---