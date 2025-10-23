[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [🌐 K-05-Сервисы](../../README.md#-k-05-сервисы)

# 📚K-05-2-Services-ClusterIP
>ClusterIP сервисы - внутренняя коммуникация между микросервисами в кластере Kubernetes, сервис-дискавери и балансировка нагрузки

---

<details>
<summary><b>🎯Зачем нужен ClusterIP?</b></summary>

---

## Проблемы микросервисной архитектуры

```
# Без ClusterIP - хрупкие связи между микросервисами
Frontend Pod: 10.244.1.2
    ↓
Backend Pod: 10.244.1.5  ← IP может измениться при перезапуске!
    ↓  
Redis Pod: 10.244.2.3    ← Как найти правильный экземпляр?
    ↓
MySQL Pod: 10.244.2.8   ← Масштабирование нарушает связи
```

**Без ClusterIP:**
- ❌ **Нестабильные IP** - Pod'ы пересоздаются с новыми адресами
- ❌ **Сложное обнаружение** - как найти нужные экземпляры сервиса
- ❌ **Нет балансировки** - ручное распределение нагрузки
- ❌ **Высокая связанность** - жесткие зависимости между компонентами

## Решение с ClusterIP

```
# ClusterIP создает стабильные endpoint'ы
Frontend Pod
    ↓
back-end Service (ClusterIP: 10.96.105.45) → Backend Pods
    ↓
redis Service (ClusterIP: 10.96.105.46)    → Redis Pods  
    ↓
mysql Service (ClusterIP: 10.96.105.47)    → MySQL Pods
```

---

</details>

<details>
<summary><b>🏗️Архитектура ClusterIP Service</b></summary>

---

## Как работает ClusterIP

```bash
# ClusterIP = виртуальный IP + балансировщик нагрузки
Service: back-end (10.96.105.45:80)
        ↓
Pod A: 10.244.1.2:8080    ← Запрос 1
Pod B: 10.244.1.3:8080    ← Запрос 2
Pod C: 10.244.2.2:8080    ← Запрос 3

# Все Pod'ы доступны через единый стабильный IP!
```

## Ключевые преимущества

```
✅ Стабильный виртуальный IP - не меняется при пересоздании Pod'ов
✅ Балансировка нагрузки - автоматическое распределение запросов
✅ Сервис-дискавери - DNS имена для простого обнаружения
✅ Автообновление - автоматически отслеживает изменения Pod'ов
✅ Изоляция - внутренняя коммуникация внутри кластера
```

---

</details>

<details>
<summary><b>📝Создание ClusterIP Service</b></summary>

---

## Базовый манифест ClusterIP

```
apiVersion: v1
kind: Service
metadata:
  name: back-end          # Имя сервиса (используется для DNS)
  labels:
    app: backend-service
spec:
  type: ClusterIP         # Тип по умолчанию (можно не указывать)
  selector:
    app: back-end         # Должен совпадать с labels Pod'ов
    tier: api
  ports:
  - port: 80              # Порт сервиса (обязательный)
    targetPort: 8080      # Порт Pod'а (опциональный)
    protocol: TCP         # Протокол (по умолчанию TCP)
```

## Упрощенный манифест (type можно опустить)

```
apiVersion: v1
kind: Service
metadata:
  name: back-end
spec:
  selector:
    app: back-end         # Находит Pod'ы с app: back-end
  ports:
  - port: 80              # port = targetPort, если targetPort не указан
```

## Обязательные поля

```
# ОБЯЗАТЕЛЬНО:
selector:                 # Как найти Pod'ы
port:                     # Порт сервиса

# ОПЦИОНАЛЬНО:
type: ClusterIP          # По умолчанию и так ClusterIP
targetPort:              # Если отличается от port
```

---

</details>

<details>
<summary><b>🏷️Селекторы и связывание</b></summary>

---

## Как Service находит Pod'ы

```
# 1. Pod'ы создаются с labels
apiVersion: v1
kind: Pod
metadata:
  name: backend-pod-1
  labels:
    app: back-end         # ← Эта метка
    tier: api
    version: "1.0"

# 2. Service использует selector
apiVersion: v1
kind: Service
metadata:
  name: back-end
spec:
  selector:
    app: back-end         # ← Находит ВСЕ Pod'ы с этой меткой
  ports:
  - port: 80
    targetPort: 8080
```

## Расширенные селекторы

```
# Несколько меток для точного отбора
selector:
  app: back-end
  tier: api
  environment: production

# Или используя matchExpressions
selector:
  matchExpressions:
  - key: app
    operator: In
    values:
    - back-end
    - api-server
```

---

</details>

<details>
<summary><b>🔍Сервис-дискавери (Service Discovery)</b></summary>

---

## DNS имена сервисов

```
# Автоматическое создание DNS записей
Service: back-end → back-end.default.svc.cluster.local

# Использование в приложениях:
# Короткая форма (в том же namespace)
DATABASE_URL = "postgresql://back-end:5432/mydb"

# Полная форма (между namespace'ами)
DATABASE_URL = "postgresql://back-end.development:5432/mydb"
```

## Практические примеры подключения

```
# Frontend Pod подключается к Backend Service
apiVersion: v1
kind: Pod
metadata:
  name: frontend-pod
spec:
  containers:
  - name: frontend
    image: nginx:latest
    env:
    - name: API_URL
      value: "http://back-end:80"    # ← Используем имя сервиса!
```

```bash
# Backend Pod подключается к Redis Service
apiVersion: v1
kind: Pod
metadata:
  name: backend-pod
spec:
  containers:
  - name: backend
    image: node:latest
    env:
    - name: REDIS_URL
      value: "redis://redis-cache:6379"  # ← Имя Redis сервиса
```

---

</details>

<details>
<summary><b>🛠️Практическое использование</b></summary>

---

## Создание и управление

```
# Создать Service
kubectl apply -f service-clusterip.yaml

# Просмотреть Services
kubectl get services
kubectl get svc

# Детальная информация
kubectl describe service back-end

# Просмотреть Endpoints (связанные Pod'ы)
kubectl get endpoints back-end

# Удалить Service
kubectl delete service back-end
```

## Пример вывода команд

```
# kubectl get services
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
back-end     ClusterIP   10.96.105.45    <none>        80/TCP    5m
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP   1d

# kubectl get endpoints back-end
NAME       ENDPOINTS                                   AGE
back-end   10.244.1.2:8080,10.244.1.3:8080,10.244.2.2:8080   5m
```

## Тестирование доступа

```
# Изнутри кластера (из любого Pod'а)
curl http://back-end
curl http://back-end.default.svc.cluster.local
curl http://10.96.105.45

# Проверить DNS разрешение
nslookup back-end
```

---

</details>

<details>
<summary><b>🔧Расширенные конфигурации</b></summary>

---

## Множественные порты

```bash
# Service с несколькими портами
apiVersion: v1
kind: Service
metadata:
  name: app-service
spec:
  selector:
    app: myapp
  ports:
  - name: http
    port: 80
    targetPort: 8080
  - name: metrics
    port: 9090
    targetPort: 9090
  - name: health
    port: 8081
    targetPort: 8081
```

## Headless Service (без ClusterIP)

```
# Headless Service - возвращает IP Pod'ов напрямую
apiVersion: v1
kind: Service
metadata:
  name: database
spec:
  clusterIP: None        # ← Важно: нет виртуального IP
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306

# DNS запрос вернет все IP Pod'ов:
# database → [10.244.1.2, 10.244.1.3, 10.244.2.2]
```

---

</details>

<details>
<summary><b>🎯Ключевые выводы</b></summary>

---

## Когда использовать ClusterIP

```
✅ Микросервисная архитектура - связь между сервисами
✅ Базы данных и кэши - внутренний доступ к stateful сервисам
✅ Внутренние API - коммуникация между компонентами приложения
✅ Service mesh - базовый строительный блок для service mesh
```

## Best Practices

1. **📌 Используйте осмысленные имена** - back-end, redis-cache, database
2. **📌 Согласованные селекторы** - одинаковые labels для Pod'ов и Services
3. **📌 Используйте DNS имена** - вместо IP адресов в конфигурациях
4. **📌 Минимальные порты** - открывайте только необходимые порты
5. **📌 Мониторьте endpoints** - следите за состоянием связанных Pod'ов

## Преимущества перед прямыми подключениями

```
✅ Стабильность - IP не меняется при пересоздании Pod'ов
✅ Балансировка - автоматическое распределение нагрузки
✅ Обнаружение - DNS-based service discovery
✅ Гибкость - можно менять Pod'ы без изменения конфигураций
✅ Масштабируемость - легко добавлять/убирать экземпляры
```

> 💡 **Совет:** ClusterIP - это основной тип Service для внутренней коммуникации в Kubernetes. Используйте его для всех связей между микросервисами внутри кластера.

---

</details>