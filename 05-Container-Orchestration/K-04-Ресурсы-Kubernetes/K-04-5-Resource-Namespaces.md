[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [🌱 K-04-Ресурсы-Kubernetes](../../README.md#-k-04-ресурсы-kubernetes)

# 📚K-04-5-Resource-Namespaces
>Namespaces - логическое разделение кластера Kubernetes для изоляции ресурсов, организации проектов и управления доступом

---

<details>
<summary><b>🎯Что такое Namespaces?</b></summary>

---

## Аналогия с марсианскими лабораториями

```
# Namespaces = виртуальные лаборатории в кластере
Кластер Kubernetes
├── default/          # Лаборатория по умолчанию
├── kube-system/      # Лаборатория системного оборудования
├── development/      # Лаборатория разработки
└── production/       # Лаборатория продакшена
```

**Namespaces** - это виртуальные кластеры внутри физического Kubernetes кластера:

- ✅ **Логическая изоляция** ресурсов и приложений
- ✅ **Организация** по командам, проектам, окружениям
- ✅ **Контроль доступа** через RBAC
- ✅ **Квоты ресурсов** для ограничения потребления

---

</details>

<details>
<summary><b>🏗️Встроенные Namespaces</b></summary>

---

## Автоматически создаваемые Namespaces

```
# 1. default - пространство по умолчанию
kubectl get pods                    # Показывает Pod'ы в default
kubectl create deployment nginx --image=nginx  # Создает в default

# 2. kube-system - системные компоненты
kubectl get pods -n kube-system     # Показывает системные Pod'ы

# 3. kube-public - публичные ресурсы
kubectl get all -n kube-public      # Ресурсы доступные всем пользователям
```

**Назначение встроенных Namespaces:**
- **default** - пользовательские ресурсы без явного указания namespace
- **kube-system** - системные компоненты (сеть, DNS, контроллеры)
- **kube-public** - ресурсы, доступные всем пользователям кластера

---

</details>

<details>
<summary><b>🛠️Создание Namespaces</b></summary>

---

## Способ 1: Через YAML манифест

```
apiVersion: v1
kind: Namespace
metadata:
  name: development
  labels:
    environment: dev
    team: frontend
```

```
# Применить манифест
kubectl apply -f namespace-dev.yaml
```

## Способ 2: Императивная команда

```
# Быстрое создание Namespace
kubectl create namespace staging

# С метками
kubectl create namespace production --dry-run=client -o yaml > prod-ns.yaml
```

## Практические примеры Namespaces

```
# Для разных сред
kubectl create namespace development
kubectl create namespace staging  
kubectl create namespace production

# Для разных команд
kubectl create namespace team-frontend
kubectl create namespace team-backend
kubectl create namespace team-data
```

---

</details>

<details>
<summary><b>🌐Работа с ресурсами в Namespaces</b></summary>

---

## Создание ресурсов в конкретном Namespace

```
# Способ 1: Параметр --namespace
kubectl run nginx --image=nginx -n development

# Способ 2: В манифесте (рекомендуется)
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  namespace: development    # ← Указываем namespace здесь
spec:
  containers:
  - name: nginx
    image: nginx:latest
```

## Просмотр ресурсов

```
# Ресурсы в конкретном namespace
kubectl get pods -n development
kubectl get services -n staging

# Ресурсы во всех namespaces
kubectl get pods --all-namespaces
kubectl get pods -A           # Сокращенная версия

# Ресурсы в текущем namespace
kubectl get pods              # Только в текущем namespace
```

---

</details>
<details>
<summary><b>🔗Межnamespace коммуникация</b></summary>

---

## DNS имена сервисов - полное объяснение

```
# Полный формат DNS имени сервиса:
servicename.namespace.svc.cluster.local

# Построчное объяснение:
servicename        → Имя Kubernetes Service (например: frontend, api, database)
.namespace         → Namespace, где находится сервис (например: production, development)  
.svc               → Обозначает, что это Service (все сервисы имеют этот суффикс)
.cluster.local     → Доменное имя кластера (настраивается при установке Kubernetes)
```

## Практические примеры

```
# Пример 1: Сервис в development namespace
frontend.development.svc.cluster.local
│         │           │   │     
│         │           │   └── Домен кластера по умолчанию
│         │           └──────── Суффикс для всех сервисов
│         └──────────── Namespace "development"
└─────────────────────── Имя сервиса "frontend"

# Пример 2: Сервис в production namespace  
api.production.svc.cluster.local
│   │           │   │     
│   │           │   └── Домен кластера
│   │           └──────── Суффикс сервиса
│   └──────────── Namespace "production"
└─────────────────────── Имя сервиса "api"
```

## Сокращенные формы обращения

```bash
# Внутри одного namespace (автоматическое разрешение):
frontend          → frontend.development.svc.cluster.local

# Между разными namespaces (указание namespace):
frontend.development → frontend.development.svc.cluster.local

# Полная форма (для отладки и особых случаев):
frontend.development.svc.cluster.local
```

## Автоматическое создание DNS записей

```
# При создании Service Kubernetes автоматически:
1. Создает DNS A-запись для сервиса
2. Добавляет ее в CoreDNS
3. Обеспечивает разрешение имени в ClusterIP

# Пример:
Service "database" в namespace "production" →
DNS: database.production.svc.cluster.local → IP: 10.96.105.45
```

---
</details>
<details>
<summary><b>⚙️Управление контекстом</b></summary>

---

## Смена текущего Namespace

```
# Посмотреть текущий контекст
kubectl config current-context

# Установить namespace по умолчанию для текущего контекста
kubectl config set-context --current --namespace=development

# Проверить текущий namespace
kubectl config view --minify | grep namespace
```

## Временное переключение

```
# Работать в конкретном namespace временно
kubectl get pods -n production
kubectl describe deployment frontend -n staging

# Альтернатива: создать алиас
alias kdev='kubectl -n development'
alias kprod='kubectl -n production'
```

---

</details>

<details>
<summary><b>📊Resource Quotas (Квоты ресурсов)</b></summary>

---

## Создание квот для Namespace

```
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: development
spec:
  hard:
    pods: "10"
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "10"
    limits.memory: 16Gi
    services: "5"
    secrets: "10"
    configmaps: "10"
```

```
# Применить квоту
kubectl apply -f resource-quota.yaml

# Просмотреть квоты
kubectl get resourcequota -n development
kubectl describe resourcequota dev-quota -n development
```

## Типы ограничений

```
# Вычислительные ресурсы
requests.cpu, requests.memory
limits.cpu, limits.memory
pods

# Объекты Kubernetes
services, secrets, configmaps
persistentvolumeclaims
```

---

</details>

<details>
<summary><b>🔐Безопасность и RBAC</b></summary>

---

## Role-Based Access Control

```
# Role для доступа только в определенном namespace
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: development
  name: developer-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps"]
  verbs: ["get", "list", "create", "update", "delete"]
```

```
# RoleBinding связывает пользователя с Role
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: development
subjects:
- kind: User
  name: alice
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer-role
  apiGroup: rbac.authorization.k8s.io
```

---

</details>

<details>
<summary><b>🛠️Практические команды</b></summary>

---

## Основные команды работы с Namespaces

```
# Создание
kubectl create namespace my-namespace

# Просмотр
kubectl get namespaces
kubectl get ns          # Сокращенная команда

# Описание
kubectl describe namespace default

# Удаление (осторожно!)
kubectl delete namespace my-namespace

# Работа с ресурсами
kubectl get pods -n development
kubectl apply -f pod.yaml -n staging
kubectl logs my-pod -n production
```

## Полезные алиасы

```
# Добавить в ~/.bashrc или ~/.zshrc
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgp-all='kubectl get pods --all-namespaces'
alias kcd='kubectl config set-context --current --namespace='
```

---

</details>

<details>
<summary><b>🎯Ключевые выводы</b></summary>

---

## Когда использовать Namespaces

```
✅ Многокомандная среда - изоляция по командам
✅ Многоокружения - dev/staging/prod в одном кластере
✅ Ограничение ресурсов - квоты для разных проектов
✅ Безопасность - RBAC для контроля доступа
✅ Организация - логическая группировка ресурсов
```

## Best Practices

1. **📌 Используйте осмысленные имена** - team-frontend, env-production
2. **📌 Указывайте namespace в манифестах** - избегайте --namespace в командах
3. **📌 Настройте ResourceQuotas** - предотвращайте исчерпание ресурсов
4. **📌 Используйте RBAC** - ограничивайте доступ по namespaces
5. **📌 Мониторьте использование** - следите за квотами и лимитами

## Распространенные ошибки

```
❌ Создание всех ресурсов в default namespace
❌ Забывают указать namespace при работе с ресурсами
❌ Не используют квоты для production namespaces
❌ Слишком много/мало namespaces
❌ Неправильные настройки RBAC
```

> 💡 **Совет:** Начинайте с простой структуры namespaces и усложняйте по мере роста кластера и команды.

---

</details>