[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [🎯 K-07-Планирование-и-ресурсы](../../README.md#-k-07-планирование-и-ресурсы)

---

# 🔄K-07-8-DaemonSets
>DaemonSets — развертывание одного Pod'а на каждом узле кластера для системных задач, мониторинга и сетевых агентов

---

<details>
<summary><b>🔍Что такое DaemonSet?</b></summary>

---

## Концепция DaemonSet

**DaemonSet** — это контроллер Kubernetes, который гарантирует запуск **одного экземпляра Pod'а на каждом узле** кластера.

**Ключевые особенности:**
- ✅ Запускает по одной копии Pod'а на каждом узле
- ✅ Автоматически добавляет Pod при добавлении нового узла
- ✅ Автоматически удаляет Pod при удалении узла
- ✅ Гарантирует наличие Pod'а на всех узлах кластера

---

## Сравнение с ReplicaSet и Deployment

```
┌─────────────────────────────────────────────────────────┐
│              ReplicaSet / Deployment                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐            │
│  │ Node 1  │    │ Node 2  │    │ Node 3  │            │
│  │         │    │         │    │         │            │
│  │ Pod A   │    │ Pod B   │    │ Pod C   │            │
│  │ Pod A   │    │ Pod B   │    │         │            │
│  │         │    │         │    │         │            │
│  └─────────┘    └─────────┘    └─────────┘            │
│                                                          │
│  Количество Pod'ов: определяется replicas               │
│  Распределение: по усмотрению Scheduler'а               │
│                                                          │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    DaemonSet                            │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐            │
│  │ Node 1  │    │ Node 2  │    │ Node 3  │            │
│  │         │    │         │    │         │            │
│  │ Pod A   │    │ Pod A   │    │ Pod A   │            │
│  │         │    │         │    │         │            │
│  └─────────┘    └─────────┘    └─────────┘            │
│                                                          │
│  Количество Pod'ов: всегда 1 на каждом узле              │
│  Распределение: по одному на каждый узел                │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

**Различия:**

| Критерий | ReplicaSet/Deployment | DaemonSet |
|----------|----------------------|-----------|
| **Количество Pod'ов** | Определяется `replicas` | Всегда 1 на каждом узле |
| **Распределение** | По усмотрению Scheduler'а | По одному на каждый узел |
| **Автоматическое добавление** | Нет | Да (при добавлении узла) |
| **Автоматическое удаление** | Нет | Да (при удалении узла) |
| **Use cases** | Приложения | Системные задачи, мониторинг |

---

</details>

<details>
<summary><b>📋Use Cases: Когда использовать DaemonSet?</b></summary>

---

## 1. Агенты мониторинга и сборщики логов

**Проблема:**
- Нужно развернуть агент мониторинга на каждой машине
- Нужно собирать логи с каждого узла
- Нельзя пропустить ни один узел

**Решение: DaemonSet**

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
        ports:
        - containerPort: 9100
```

**Преимущества:**
- ✅ Автоматически развертывается на всех узлах
- ✅ Автоматически добавляется при добавлении нового узла
- ✅ Не нужно вручную управлять агентами

---

## 2. Системные компоненты Kubernetes

**Пример: kube-proxy**

`kube-proxy` — необходимый компонент каждого узла, который можно развернуть как DaemonSet.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: kube-proxy
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: kube-proxy
  template:
    metadata:
      labels:
        k8s-app: kube-proxy
    spec:
      containers:
      - name: kube-proxy
        image: k8s.gcr.io/kube-proxy:v1.24.0
```

> 💡 **Факт:** `kubeadm` использует DaemonSet для развертывания `kube-proxy` в кластере.

---

## 3. Сетевые агенты и плагины

**Пример: Weave-net, Flannel, Calico**

Сетевые решения Kubernetes требуют развертывания агента на каждом узле.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: weave-net
  namespace: kube-system
spec:
  selector:
    matchLabels:
      name: weave-net
  template:
    metadata:
      labels:
        name: weave-net
    spec:
      containers:
      - name: weave
        image: weaveworks/weave-kube:latest
```

**Зачем нужны:**
- Настройка сетевых политик
- Управление сетевыми интерфейсами
- Маршрутизация трафика между Pod'ами

---

## 4. Другие use cases

**Системные задачи:**
- Антивирусное сканирование
- Обновление безопасности
- Сбор метрик производительности
- Резервное копирование

**Общая характеристика:**
- Задача должна выполняться на **каждом узле**
- Не зависит от количества Pod'ов приложения
- Критична для работы кластера или мониторинга

---

</details>

<details>
<summary><b>🛠️Создание DaemonSet</b></summary>

---

## Базовая структура YAML

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
        ports:
        - containerPort: 9100
```

**Ключевые элементы:**
- `apiVersion: apps/v1` — версия API для DaemonSet
- `kind: DaemonSet` — тип ресурса
- `spec.selector` — селектор для связи DaemonSet с Pod'ами
- `spec.template` — шаблон Pod'а (аналогично ReplicaSet)

> ⚠️ **Важно:** Метки в `selector.matchLabels` должны совпадать с метками в `template.metadata.labels`.

---

## Полный пример: DaemonSet для мониторинга

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      containers:
      - name: node-exporter
        image: prom/node-exporter:v1.5.0
        ports:
        - containerPort: 9100
          name: metrics
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: sys
          mountPath: /host/sys
          readOnly: true
      volumes:
      - name: proc
        hostPath:
          path: /proc
      - name: sys
        hostPath:
          path: /sys
      hostNetwork: true
      hostPID: true
```

**Особенности:**
- Использует `hostPath` для доступа к системным директориям
- `hostNetwork: true` для доступа к сетевым интерфейсам узла
- `hostPID: true` для доступа к процессам узла

---

## Команды для работы с DaemonSet

### Создание DaemonSet

```bash
# Из YAML файла
kubectl create -f daemonset.yaml

# Или напрямую
kubectl create daemonset node-exporter \
  --image=prom/node-exporter:latest
```

### Просмотр DaemonSet

```bash
# Список всех DaemonSet
kubectl get daemonset

# Сокращенная форма
kubectl get ds

# С указанием namespace
kubectl get ds -n kube-system

# Детальная информация
kubectl describe daemonset node-exporter
```

### Просмотр Pod'ов DaemonSet

```bash
# Все Pod'ы DaemonSet
kubectl get pods -l app=node-exporter

# На конкретном узле
kubectl get pods -l app=node-exporter --field-selector spec.nodeName=node01
```

### Удаление DaemonSet

```bash
# Удаление DaemonSet (Pod'ы также удалятся)
kubectl delete daemonset node-exporter

# Из файла
kubectl delete -f daemonset.yaml
```

---

</details>

<details>
<summary><b>⚙️Как работает DaemonSet?</b></summary>

---

## Механизм размещения Pod'ов

DaemonSet должен гарантировать:
- ✅ По одному Pod'у на каждом узле
- ✅ Ни больше, ни меньше
- ✅ Автоматическое добавление при добавлении узла
- ✅ Автоматическое удаление при удалении узла

---

## История: До версии Kubernetes v1.12

**Подход: использование `nodeName`**

DaemonSet вручную устанавливал `nodeName` в спецификации каждого Pod'а:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: node-exporter-node01
spec:
  nodeName: node01  # Прямое указание узла
  containers:
  - name: node-exporter
    image: prom/node-exporter:latest
```

**Как это работало:**
1. DaemonSet создавал Pod для каждого узла
2. Устанавливал `nodeName` в спецификации Pod'а
3. Обходил Scheduler, размещая Pod напрямую на узле

**Проблемы:**
- ❌ Обходил стандартный Scheduler
- ❌ Не учитывал Taints, Tolerations, Node Affinity
- ❌ Ограниченная гибкость

---

## Современный подход: После версии v1.12

**Подход: использование Node Affinity**

DaemonSet использует стандартный Scheduler с Node Affinity:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: node-exporter-node01
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/hostname
            operator: In
            values:
            - node01
  containers:
  - name: node-exporter
    image: prom/node-exporter:latest
```

**Как это работает:**
1. DaemonSet создает Pod с Node Affinity
2. Node Affinity указывает на конкретный узел через `kubernetes.io/hostname`
3. Стандартный Scheduler размещает Pod на нужном узле
4. Учитываются все правила планирования (Taints, Tolerations, и т.д.)

**Преимущества:**
- ✅ Использует стандартный Scheduler
- ✅ Учитывает Taints, Tolerations, Node Affinity
- ✅ Больше гибкости и контроля

---

## Схема работы DaemonSet

```
┌─────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                   │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  DaemonSet Controller                                    │
│  ┌──────────────────────────────────────┐              │
│  │ 1. Мониторит узлы кластера           │              │
│  │ 2. Проверяет наличие Pod'ов          │              │
│  │ 3. Создает Pod для нового узла       │              │
│  │ 4. Удаляет Pod при удалении узла     │              │
│  └──────────────────────────────────────┘              │
│           │                                              │
│           ▼                                              │
│  ┌──────────────────────────────────────┐              │
│  │  Node 1:  Pod есть ✅                 │              │
│  │  Node 2:  Pod есть ✅                 │              │
│  │  Node 3:  Pod есть ✅                 │              │
│  │  Node 4:  Pod нет ❌ → Создать!      │              │
│  └──────────────────────────────────────┘              │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

**Процесс:**
1. DaemonSet Controller мониторит все узлы кластера
2. Для каждого узла проверяет наличие Pod'а с нужными метками
3. Если Pod отсутствует → создает новый Pod с Node Affinity на этот узел
4. Если узел удален → удаляет Pod с этого узла
5. Гарантирует ровно один Pod на каждом узле

---

</details>

<details>
<summary><b>📊Практические примеры</b></summary>

---

## Пример 1: Node Exporter для Prometheus

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  namespace: monitoring
  labels:
    app: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      containers:
      - name: node-exporter
        image: prom/node-exporter:v1.5.0
        args:
        - --path.procfs=/host/proc
        - --path.sysfs=/host/sys
        - --collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($|/)
        ports:
        - containerPort: 9100
          name: metrics
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: sys
          mountPath: /host/sys
          readOnly: true
        - name: root
          mountPath: /rootfs
          readOnly: true
      volumes:
      - name: proc
        hostPath:
          path: /proc
      - name: sys
        hostPath:
          path: /sys
      - name: root
        hostPath:
          path: /
      hostNetwork: true
      hostPID: true
```

---

## Пример 2: Fluentd для сбора логов

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
  namespace: kube-system
  labels:
    app: fluentd
spec:
  selector:
    matchLabels:
      app: fluentd
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluent/fluentd-kubernetes-daemonset:v1-debian-elasticsearch
        env:
        - name: FLUENT_ELASTICSEARCH_HOST
          value: "elasticsearch.logging.svc.cluster.local"
        - name: FLUENT_ELASTICSEARCH_PORT
          value: "9200"
        resources:
          requests:
            memory: "200Mi"
            cpu: "100m"
          limits:
            memory: "500Mi"
            cpu: "500m"
        volumeMounts:
        - name: varlog
          mountPath: /var/log
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
```

---

## Пример 3: DaemonSet с Tolerations

Если нужно развернуть DaemonSet на master-узлах (которые обычно имеют Taints):

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      - key: node-role.kubernetes.io/control-plane
        effect: NoSchedule
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
```

> 💡 **Важно:** Без Tolerations DaemonSet не сможет разместить Pod на master-узлах из-за Taints.

---

## Пример 4: DaemonSet с Node Selector

Если нужно развернуть DaemonSet только на определенных узлах:

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      nodeSelector:
        node-type: worker
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
```

**Результат:**
- DaemonSet развернется только на узлах с меткой `node-type=worker`
- Узлы без этой метки будут пропущены

---

</details>

<details>
<summary><b>🔧Проверка и отладка</b></summary>

---

## Проверка статуса DaemonSet

```bash
# Список DaemonSet с деталями
kubectl get ds -o wide

# Вывод:
# NAME              DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
# node-exporter     3         3         3       3            3           <none>          5m
```

**Поля:**
- `DESIRED` — желаемое количество Pod'ов (равно количеству узлов)
- `CURRENT` — текущее количество Pod'ов
- `READY` — количество готовых Pod'ов
- `UP-TO-DATE` — количество Pod'ов с актуальным шаблоном
- `AVAILABLE` — количество доступных Pod'ов

---

## Проверка Pod'ов DaemonSet

```bash
# Все Pod'ы DaemonSet
kubectl get pods -l app=node-exporter -o wide

# Вывод:
# NAME                    READY   STATUS    RESTARTS   AGE   IP           NODE
# node-exporter-node01    1/1     Running   0          5m    10.244.1.5   node01
# node-exporter-node02    1/1     Running   0          5m    10.244.2.3   node02
# node-exporter-node03    1/1     Running   0          5m    10.244.3.2   node03
```

**Проверка:**
- ✅ По одному Pod'у на каждом узле
- ✅ Все Pod'ы в состоянии `Running`
- ✅ Все Pod'ы готовы (`READY 1/1`)

---

## Отладка проблем

### Проблема 1: Pod не создается на узле

```bash
# Проверить события DaemonSet
kubectl describe daemonset node-exporter

# Проверить события Pod'а
kubectl describe pod node-exporter-node01
```

**Возможные причины:**
- Taints на узле без соответствующих Tolerations
- Node Selector не соответствует меткам узла
- Недостаточно ресурсов на узле

### Проблема 2: Pod не может запуститься

```bash
# Просмотр логов Pod'а
kubectl logs node-exporter-node01

# Просмотр событий Pod'а
kubectl describe pod node-exporter-node01
```

**Возможные причины:**
- Ошибка в образе контейнера
- Проблемы с правами доступа
- Конфликт портов

---

## Проверка распределения Pod'ов

```bash
# Подсчет Pod'ов на каждом узле
kubectl get pods -l app=node-exporter -o wide | \
  awk '{print $7}' | sort | uniq -c

# Вывод:
# 1 node01
# 1 node02
# 1 node03
```

**Ожидаемый результат:**
- По одному Pod'у на каждом узле
- Количество Pod'ов = количество узлов

---

</details>

<details>
<summary><b>💡Лучшие практики</b></summary>

---

## Рекомендации по использованию DaemonSet

### 1. Используйте для системных задач

**Правильно:**
- Агенты мониторинга
- Сетевые плагины
- Системные компоненты (kube-proxy)

**Неправильно:**
- Приложения (используйте Deployment)
- Базы данных (используйте StatefulSet)

---

### 2. Указывайте ресурсы

```yaml
spec:
  template:
    spec:
      containers:
      - name: node-exporter
        image: prom/node-exporter:latest
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
```

**Почему:**
- DaemonSet работает на каждом узле
- Недостаток ресурсов может повлиять на все узлы
- Помогает Scheduler'у оптимально размещать Pod'ы

---

### 3. Используйте Tolerations для master-узлов

```yaml
spec:
  template:
    spec:
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      - key: node-role.kubernetes.io/control-plane
        effect: NoSchedule
```

**Почему:**
- Master-узлы обычно имеют Taints
- Без Tolerations DaemonSet не сможет разместить Pod на master-узлах

---

### 4. Используйте правильные метки

```yaml
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
```

**Правило:**
- Метки в `selector.matchLabels` должны совпадать с метками в `template.metadata.labels`
- Используйте уникальные метки для каждого DaemonSet

---

### 5. Мониторьте состояние DaemonSet

```bash
# Регулярно проверяйте статус
kubectl get ds -A

# Проверяйте логи Pod'ов
kubectl logs -l app=node-exporter --tail=100
```

---

## Типичные ошибки

### Ошибка 1: Несовпадающие метки

**Проблема:**
```yaml
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        name: node-exporter  # Не совпадает!
```

**Решение:**
```yaml
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter  # Совпадает!
```

### Ошибка 2: Отсутствие Tolerations для master-узлов

**Проблема:**
- DaemonSet не развертывается на master-узлах

**Решение:**
- Добавьте Tolerations в спецификацию Pod'а

### Ошибка 3: Использование DaemonSet для приложений

**Проблема:**
- Использование DaemonSet для развертывания приложений

**Решение:**
- Используйте Deployment или ReplicaSet для приложений
- DaemonSet только для системных задач

---

</details>

<details>
<summary><b>📚Резюме</b></summary>

---

✅ **DaemonSet** — контроллер для развертывания одного Pod'а на каждом узле кластера

✅ **Ключевые особенности:**
- Запускает по одному Pod'у на каждом узле
- Автоматически добавляет Pod при добавлении узла
- Автоматически удаляет Pod при удалении узла

✅ **Use cases:**
- Агенты мониторинга (Node Exporter, Prometheus)
- Сборщики логов (Fluentd, Fluent Bit)
- Сетевые плагины (Weave-net, Flannel, Calico)
- Системные компоненты (kube-proxy)

✅ **Механизм работы:**
- До v1.12: использовал `nodeName` для прямого размещения
- После v1.12: использует Node Affinity со стандартным Scheduler'ом

✅ **Лучшие практики:**
- Используйте для системных задач, а не для приложений
- Указывайте ресурсы (requests и limits)
- Используйте Tolerations для master-узлов
- Проверяйте метки в selector и template

---

</details>