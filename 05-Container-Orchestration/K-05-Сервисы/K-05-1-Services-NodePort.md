[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [🌐 K-05-Сервисы](../../README.md#-k-05-сервисы)

# 📚K-05-1-Services-NodePort
>NodePort сервисы - обеспечение внешнего доступа к приложениям Kubernetes через статические порты на всех нодах кластера

---

<details>
<summary><b>🎯Зачем нужны Services?</b></summary>

---

## Проблемы без Services

```
# Без Service невозможно внешнее подключение
Node: 192.168.1.2        Laptop: 192.168.1.10
┌─────────────────┐      ❌ Не может подключиться
│ Pod: 10.244.0.2 │      к Pod: 10.244.0.2
│   (nginx:80)    │      (разные сети)
└─────────────────┘
```

**Без Services:**
- ❌ Нет доступа к приложениям извне кластера
- ❌ Сложная коммуникация между микросервисами
- ❌ Нет балансировки нагрузки между Pod'ами
- ❌ Высокая связанность компонентов

## Решение с Services

```
# Service обеспечивает:
✅ Внешний доступ к приложениям
✅ Балансировку нагрузки между Pod'ами
✅ Стабильные endpoint'ы для микросервисов
✅ Автоматическое обнаружение сервисов
```

---

</details>

<details>
<summary><b>🌐Типы Services в Kubernetes</b></summary>

---

## Три основных типа Services

+кod
# 1. ClusterIP (по умолчанию)
# Виртуальный IP для внутренней коммуникации
Frontend → ClusterIP:8080 → Backend Pods

# 2. NodePort
# Внешний доступ через порт на нодах
Browser → NodeIP:30008 → Service → Pod:80

# 3. LoadBalancer
# Облачный балансировщик нагрузки
Internet → CloudLB → Service → Pods
```

## Сравнение типов Services

| Тип | Назначение | Видимость | Использование |
|-----|------------|-----------|---------------|
| **ClusterIP** | Внутренняя коммуникация | Только внутри кластера | Микросервисы, БД |
| **NodePort** | Внешний доступ | Через порты нод | Разработка, тестирование |
| **LoadBalancer** | Продвинутый внешний доступ | Через облачный LB | Продакшен, облака |

---

</details>

<details>
<summary><b>🔧NodePort Service - архитектура</b></summary>

---

## Три порта в NodePort Service

```
# NodePort Service использует 3 порта:
Node: 192.168.1.2:30008 ← NodePort (внешний доступ)
        ↓
Service: 10.96.105.45:80 ← Port (сервисный порт)  
        ↓
Pod: 10.244.0.2:80 ← targetPort (порт приложения)
```

### Детальное объяснение портов:

```
1. targetPort: 80    → Порт контейнера в Pod (где работает приложение)
2. port: 80          → Порт самого Service (виртуальный сервер)
3. nodePort: 30008   → Порт на ноде для внешнего доступа
```

## Диапазоны портов

```
# NodePort диапазон: 30000-32767
# Автоматическое выделение, если не указан

# Примеры:
nodePort: 30008    # Указан вручную
nodePort: 30567    # Автоматически выделен
```

---

</details>

<details>
<summary><b>📝Создание NodePort Service</b></summary>

---

## Базовый манифест NodePort

```
apiVersion: v1
kind: Service
metadata:
  name: web-service
  labels:
    app: webapp
spec:
  type: NodePort           # ⚠️ Явно указываем тип
  selector:
    app: webapp            # Должен совпадать с labels Pod'ов
  ports:
  - port: 80               # Порт Service (обязательный)
    targetPort: 80         # Порт Pod'а (опциональный, по умолчанию = port)
    nodePort: 30008        # Порт ноды (опциональный, 30000-32767)
```

## Обязательные и опциональные поля

```
# ОБЯЗАТЕЛЬНО:
type: NodePort            # Тип сервиса
selector:                 # Селектор для поиска Pod'ов
port:                     # Порт сервиса

# ОПЦИОНАЛЬНО:
targetPort:               # Если отличается от port
nodePort:                 # Если нужен конкретный порт
```

---

</details>

<details>
<summary><b>🏷️Селекторы и связывание с Pod'ами</b></summary>

---

## Как Service находит Pod'ы

```
# 1. Pod создается с labels
apiVersion: v1
kind: Pod
metadata:
  name: web-pod
  labels:
    app: webapp           # ← Эта метка
    tier: frontend
spec:
  containers:
  - name: nginx
    image: nginx:latest

# 2. Service использует selector с такими же labels
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: webapp           # ← Находит Pod'ы с этой меткой
    # tier: frontend      # Можно добавить дополнительные метки
  ports:
  - port: 80
    targetPort: 80
```

## Проверка связывания

```
# Посмотреть Service
kubectl get services

# Посмотреть Endpoints (связанные Pod'ы)
kubectl get endpoints web-service

# Детальная информация
kubectl describe service web-service
```

---

</details>

<details>
<summary><b>⚖️Балансировка нагрузки</b></summary>

---

## Множественные Pod'ы

```
# Service автоматически балансирует нагрузку между Pod'ами
Service: web-service
        ↓
Pod A: 10.244.1.2:80    ← Запрос 1
Pod B: 10.244.1.3:80    ← Запрос 2  
Pod C: 10.244.2.2:80    ← Запрос 3
```

## Алгоритм балансировки

```
# Kubernetes использует случайный алгоритм
Запрос 1 → Pod B
Запрос 2 → Pod A
Запрос 3 → Pod C
Запрос 4 → Pod B
```

## Мульти-нодовая архитектура

```
# Service работает на ВСЕХ нодах кластера
Node1: 192.168.1.2:30008 → Service → Pod A (на Node1)
Node2: 192.168.1.3:30008 → Service → Pod B (на Node2)
Node3: 192.168.1.4:30008 → Service → Pod C (на Node1)

# Доступно с ЛЮБОЙ ноды по одинаковому порту!
```

---

</details>

<details>
<summary><b>🛠️Практическое использование</b></summary>

---

## Создание и управление

```
# Создать Service
kubectl apply -f service-nodeport.yaml

# Просмотреть Services
kubectl get services
kubectl get svc           # Сокращенная команда

# Детальная информация
kubectl describe service web-service

# Удалить Service
kubectl delete service web-service
```

## Пример вывода kubectl get services

```
NAME          TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
web-service   NodePort   10.96.105.45    <none>        80:30008/TCP   5m
kubernetes    ClusterIP  10.96.0.1       <none>        443/TCP        1d
```

## Тестирование доступа

+кod
# Доступ через любой узел кластера
curl http://192.168.1.2:30008
curl http://192.168.1.3:30008
curl http://192.168.1.4:30008

# Все ведут к одному Service!
```

---

</details>

<details>
<summary><b>🔧Расширенные конфигурации</b></summary>

---

## Множественные порты

```
# Service с несколькими портами
apiVersion: v1
kind: Service
metadata:
  name: app-service
spec:
  type: NodePort
  selector:
    app: myapp
  ports:
  - name: http
    port: 80
    targetPort: 8080
    nodePort: 30008
  - name: https
    port: 443
    targetPort: 8443
    nodePort: 30443
  - name: metrics
    port: 9090
    targetPort: 9090
    # nodePort не указан - будет выделен автоматически
```

## Протоколы

```
# Указание протокола
ports:
- port: 53
  targetPort: 53
  protocol: UDP        # По умолчанию TCP
- port: 80
  targetPort: 80
  protocol: TCP
```

---

</details>

<details>
<summary><b>🎯Ключевые выводы</b></summary>

---

## Преимущества NodePort

```
✅ Простой внешний доступ к приложениям
✅ Автоматическая балансировка нагрузки
✅ Работает на всех нодах кластера
✅ Автоматическое обновление при изменении Pod'ов
✅ Подходит для разработки и тестирования
```

## Best Practices

1. **📌 Используйте осмысленные селекторы** - четкая связь с Pod'ами
2. **📌 Минимальные привилегии портов** - только необходимые порты
3. **📌 Используйте автоматические nodePort** если не нужен конкретный порт
4. **📌 Тестируйте со всех нод** - гарантия доступности
5. **📌 Для продакшена** рассмотрите LoadBalancer или Ingress

## Ограничения NodePort

```
❌ Порт должен быть в диапазоне 30000-32767
❌ Нужно знать IP нод для доступа
❌ Не идеален для продакшена
❌ Нет SSL/TLS терминации
❌ Нет доменных имен
```

> 💡 **Совет:** NodePort отлично подходит для разработки и тестирования. Для продакшена используйте LoadBalancer или Ingress контроллеры.

---

</details>