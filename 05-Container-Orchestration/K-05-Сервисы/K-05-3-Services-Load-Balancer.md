[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [🌐 K-05-Сервисы](../../README.md#-k-05-сервисы)

# 📚K-05-3-Services-Load-Balancer
>LoadBalancer сервисы - внешний доступ к приложениям через облачные балансировщики нагрузки, автоматическая настройка и интеграция с облачными провайдерами

---

<details>
<summary><b>🎯Проблема NodePort для продакшена</b></summary>

---

## Ограничения NodePort во внешнем доступе

```
# С NodePort - множество точек входа
Node1: 192.168.1.70:30008   ← Приложение голосования
Node2: 192.168.1.71:30008   ← Тот же сервис, другой IP
Node3: 192.168.1.72:30008   ← Еще одна точка входа
Node4: 192.168.1.73:30008   ← И еще одна...

# Пользователям нужно давать 4 разных URL!
```

**Проблемы NodePort для продакшена:**
- ❌ **Множество IP-адресов** - пользователи не знают какой использовать
- ❌ **Нет единого домена** - сложно настроить DNS
- ❌ **Ручная балансировка** - нет автоматического распределения трафика
- ❌ **Нет health checks** - запросы могут отправляться на неработающие ноды

## Решение: LoadBalancer Service

```
# LoadBalancer создает единую точку входа
Пользователи → Load Balancer (example-vote.com) → Все ноды кластера
```

---

</details>

<details>
<summary><b>🏗️Архитектура LoadBalancer</b></summary>

---

## Как работает LoadBalancer

+кod
# LoadBalancer = облачный балансировщик + автоматическая настройка
Internet
    ↓
Cloud Load Balancer (external-IP)  ← Автоматически создается
    ↓
Service: LoadBalancer
    ↓
[Node1:30008, Node2:30008, Node3:30008, Node4:30008]
    ↓
[Pod A, Pod B, Pod C, Pod D]  ← Балансировка на двух уровнях
```

## Преимущества LoadBalancer

```
✅ Единый внешний IP/домен для пользователей
✅ Автоматическая настройка балансировщика
✅ Health checks и мониторинг
✅ Интеграция с облачной инфраструктурой
✅ Автомасштабирование под нагрузку
```

---

</details>

<details>
<summary><b>☁️Поддерживаемые облачные провайдеры</b></summary>

---

## Основные поддерживаемые платформы

```
# AWS
type: LoadBalancer → создает ELB (Elastic Load Balancer)

# Google Cloud Platform  
type: LoadBalancer → создает Cloud Load Balancer

# Microsoft Azure
type: LoadBalancer → создает Azure Load Balancer

# Alibaba Cloud
type: LoadBalancer → создает SLB (Server Load Balancer)
```

## Проверка поддержки

```
# Если провайдер не поддерживается:
type: LoadBalancer → ведет себя как type: NodePort

# Проверить в документации:
- OpenStack Cloud Provider
- VMware vSphere
- DigitalOcean
- Oracle Cloud Infrastructure
```

> ⚠️ **Важно:** LoadBalancer работает только с поддерживаемыми облачными провайдерами. В on-premise средах требуется дополнительная настройка.

---

</details>

<details>
<summary><b>📝Создание LoadBalancer Service</b></summary>

---

## Базовый манифест LoadBalancer

```
apiVersion: v1
kind: Service
metadata:
  name: vote-service
  labels:
    app: vote
spec:
  type: LoadBalancer        # ⚠️ Ключевое отличие!
  selector:
    app: vote-frontend      # Связь с Pod'ами приложения
  ports:
  - port: 80               # Порт балансировщика
    targetPort: 80         # Порт Pod'ов
    protocol: TCP
```

## Расширенная конфигурация

```
# С аннотациями для конкретного облачного провайдера
apiVersion: v1
kind: Service
metadata:
  name: result-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    cloud.google.com/load-balancer-type: "Internal"
spec:
  type: LoadBalancer
  selector:
    app: result-frontend
  ports:
  - name: http
    port: 80
    targetPort: 80
  - name: https
    port: 443
    targetPort: 443
```

---

</details>

<details>
<summary><b>🛠️Практическое использование</b></summary>

---

## Создание и мониторинг

+кod
# Создать LoadBalancer Service
kubectl apply -f service-loadbalancer.yaml

# Просмотреть Services (ждем EXTERNAL-IP)
kubectl get services -w

# Детальная информация
kubectl describe service vote-service

# Проверить балансировщик в облачной консоли
```

## Пример вывода kubectl get services

```
# Инициализация (внешний IP еще не назначен)
NAME           TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
vote-service   LoadBalancer   10.96.105.45    <pending>     80:30008/TCP   30s

# Готовность (внешний IP назначен)
NAME           TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
vote-service   LoadBalancer   10.96.105.45    34.107.100.200   80:30008/TCP   2m
```

## Тестирование доступа

```
# Использовать внешний IP для доступа
curl http://34.107.100.200

# Или настроить DNS запись
vote.example.com → 34.107.100.200
```

---

</details>

<details>
<summary><b>🔧Облачные специфики</b></summary>

---

## AWS специфичные аннотации

```
apiVersion: v1
kind: Service
metadata:
  name: vote-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "arn:aws:acm..."
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
spec:
  type: LoadBalancer
  # ...
```

## GCP специфичные аннотации

```
apiVersion: v1
kind: Service
metadata:
  name: vote-service
  annotations:
    cloud.google.com/load-balancer-type: "Internal"
    networking.gke.io/load-balancer-type: "Internal"
spec:
  type: LoadBalancer
  # ...
```

## Azure специфичные аннотации

```
apiVersion: v1
kind: Service
metadata:
  name: vote-service
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
    service.beta.kubernetes.io/azure-load-balancer-ipv4: "10.240.0.25"
spec:
  type: LoadBalancer
  # ...
```

---

</details>

<details>
<summary><b>⚖️Сравнение с другими типами Services</b></summary>

---

## Когда использовать каждый тип

```
# ClusterIP - внутренняя коммуникация
Микросервисы, БД, кэши → type: ClusterIP

# NodePort - разработка и тестирование  
Локальный доступ, демо → type: NodePort

# LoadBalancer - продакшен внешних сервисов
Публичные приложения, API → type: LoadBalancer
```

## Иерархия Services

```
# LoadBalancer включает функциональность всех типов:
LoadBalancer → имеет внешний IP
    ↓
NodePort → открывает порты на нодах  
    ↓
ClusterIP → имеет внутренний IP для сервис-дискавери
```

---

</details>

<details>
<summary><b>🚫Ограничения и альтернативы</b></summary>

---

## Ограничения LoadBalancer

```
❌ Только для поддерживаемых облачных провайдеров
❌ Стоимость облачного балансировщика
❌ Один LoadBalancer на Service (может быть дорого)
❌ Ограниченная кастомизация через аннотации
❌ Нет advanced routing (path-based, host-based)
```

## Альтернативы для on-premise

```
# MetalLB - LoadBalancer для bare-metal
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml

# Ingress Controller + NodePort
nginx-ingress, traefik, haproxy-ingress

# External Load Balancer + NodePort
HAProxy, Nginx, F5 BIG-IP
```

---

</details>

<details>
<summary><b>🎯Ключевые выводы</b></summary>

---

## Преимущества LoadBalancer

```
✅ Автоматическая настройка облачного балансировщика
✅ Единая точка входа для пользователей
✅ Интеграция с health checks и мониторингом
✅ Поддержка SSL/TLS терминации
✅ Автомасштабирование под нагрузку
```

## Best Practices

1. **📌 Используйте для публичных сервисов** - веб-приложения, API
2. **📌 Настройте DNS записи** - вместо прямых IP адресов
3. **📌 Мониторьте стоимость** - облачные балансировщики могут быть дорогими
4. **📌 Используйте аннотации** для кастомизации под конкретный облачный провайдер
5. **📌 Рассмотрите Ingress** для advanced routing и множества сервисов

## Практические сценарии

```
✅ Публичное веб-приложение → LoadBalancer
✅ Внутренний микросервис → ClusterIP  
✅ Разработка/тестирование → NodePort
✅ Множество сервисов с routing → Ingress
```

> 💡 **Совет:** Для окружений без облачного провайдера используйте MetalLB или комбинацию Ingress Controller + NodePort.

---

</details>