[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [🌱 K-04-Ресурсы-Kubernetes](../../README.md#-k-04-ресурсы-kubernetes)

# 🔹K-04-3-Controller-ReplicaSet
>ReplicaSet - контроллер, обеспечивающий стабильное количество Pod'ов, поддерживает желаемое состояние и автоматически восстанавливает упавшие контейнеры

<details>
<summary><b>🔍 Что такое ReplicaSet?</b></summary>

---

ReplicaSet гарантирует, что **определенное количество экземпляров Pod'ов** будет запущено в кластере Kubernetes в любой момент времени.

```
# ReplicaSet обеспечивает высокую доступность
Node1:                          Node2:
┌─────────────────┐             ┌─────────────────┐
│      Pod A      │             │      Pod C      │
│ ┌─────────────┐ │             │ ┌─────────────┐ │
│ │  Container  │ │             │ │  Container  │ │
│ │   (app)     │ │             │ │   (app)     │ │
│ └─────────────┘ │             │ └─────────────┘ │
└─────────────────┘             └─────────────────┘
┌─────────────────┐
│      Pod B      │
│ ┌─────────────┐ │
│ │  Container  │ │
│ │   (app)     │ │
│ └─────────────┘ │
└─────────────────┘
```

**Преимущества ReplicaSet:**
- ✅ **Высокая доступность** - несколько экземпляров приложения
- ✅ **Автовосстановление** - автоматический перезапуск упавших Pod'ов
- ✅ **Балансировка нагрузки** - распределение между Pod'ами
- ✅ **Автомасштабирование** - легко изменить количество реплик

> ⚠️ **Важное замечание:** В современных Kubernetes рекомендуется использовать **Deployment**, который управляет ReplicaSet'ами автоматически.

---

</details>

<details>
<summary><b>🆚ReplicaSet vs Replication Controller</b></summary>

---

```
# ReplicationController (устарел)
apiVersion: v1
kind: ReplicationController

# ReplicaSet (рекомендуется)
apiVersion: apps/v1
kind: ReplicaSet
```

| Аспект | ReplicationController | ReplicaSet |
|--------|---------------------|------------|
| **Статус** | Устаревший | ✅ Рекомендуемый |
| **apiVersion** | `v1` | `apps/v1` |
| **Селектор** | Простой (опциональный) | Расширенный (обязательный) |
| **Возможности** | Базовые | Расширенные условия отбора |

> 💡 **Важно:** Всегда используйте ReplicaSet вместо ReplicationController!

---

</details>

<details>
<summary><b>📋Структура ReplicaSet манифеста</b></summary>

---

```
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      tier: frontend
    matchExpressions:
      - {key: tier, operator: In, values: [frontend]}
  template:
    metadata:
      labels:
        app: guestbook
        tier: frontend
    spec:
      containers:
      - name: php-redis
        image: gcr.io/google_samples/gb-frontend:v3
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        env:
        - name: GET_HOSTS_FROM
          value: env
        ports:
        - containerPort: 80
```

### Обязательные поля:

- **`.spec.template`** - шаблон Pod'а (формат как у Pod, но без apiVersion/kind)
- **`.spec.template.metadata.labels`** - метки Pod'а
- **`.spec.selector`** - селектор меток (обязательный для ReplicaSet!)

### Ключевые параметры:

- **`.spec.replicas`** - количество экземпляров Pod'ов (по умолчанию 1)

---

</details>

<details>
<summary><b>🎯Как работает селектор?</b></summary>

---

```
# ReplicaSet может управлять Pod'ами, созданными ДО него
# Существующий Pod
apiVersion: v1
kind: Pod
metadata:
  name: existing-pod
  labels:
    app: myapp    # ← Такая же метка!

# ReplicaSet с selector
selector:
  matchLabels:
    app: myapp    # ← Найдет существующий Pod!
```

ReplicaSet управляет **всеми Pod'ами**, чьи метки соответствуют селектору, независимо от того:
- Созданы ли они самим ReplicaSet
- Созданы другим процессом (Deployment)
- Созданы администратором вручную

**Важно:** Убедитесь, что `selector.matchLabels` совпадает с `template.metadata.labels`!

---

</details>

<details>
<summary><b>🛠️Практическая работа</b></summary>

---

### Создание ReplicaSet

```
# Создать ReplicaSet из YAML-файла
kubectl create -f frontend.yaml

# Или применить (более современно)
kubectl apply -f frontend.yaml
```

### Просмотр состояния

```
# Посмотреть ReplicaSet
kubectl get replicaset
kubectl get rs  # сокращенная команда

# Детальная информация
kubectl describe rs/frontend
```

**Пример вывода:**
```
Name:         frontend
Namespace:    default
Selector:     tier=frontend,tier in (frontend)
Replicas:     3 current / 3 desired
Pods Status:  3 Running / 0 Waiting / 0 Succeeded / 0 Failed
Events:
  Normal  SuccessfulCreate  Created pod: frontend-qhloh
  Normal  SuccessfulCreate  Created pod: frontend-dnjpy
  Normal  SuccessfulCreate  Created pod: frontend-9si5l
```

### Масштабирование

```
# Масштабировать вручную
kubectl scale rs frontend --replicas=5

# Или изменить replicas в YAML и применить
kubectl apply -f frontend.yaml
```

### Удаление ReplicaSet

**Стандартное удаление (с Pod'ами):**
```
kubectl delete rs frontend
```

*Kubectl автоматически:*
1. *Масштабирует до 0 реплик*
2. *Удаляет все Pod'ы*
3. *Удаляет ReplicaSet*

**Удаление только ReplicaSet (Pod'ы остаются):**
```
kubectl delete rs frontend --cascade=false
```

### Изоляция Pod'а от ReplicaSet

```
kubectl label pod frontend-xyz tier=debug --overwrite
```

ReplicaSet создаст новый Pod взамен "отвязанного".

---

</details>

<details>
<summary><b>📈Автоматическое масштабирование (HPA)</b></summary>

---

```
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: frontend-scaler
spec:
  scaleTargetRef:
    kind: ReplicaSet
    name: frontend
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 50
```

**Применение:**
```bash
kubectl create -f hpa-rs.yaml
```

---

</details>

<details>
<summary><b>🔄Альтернативы ReplicaSet</b></summary>

---

| Объект | Назначение | Когда использовать |
|--------|------------|-------------------|
| **Deployment** ✅ | Управление приложениями с обновлениями | **Рекомендуется для большинства случаев** |
| **StatefulSet** | Stateful-приложения с устойчивыми идентификаторами | Базы данных, кэши |
| **DaemonSet** | По одному Pod'у на каждой ноде | Агенты мониторинга, логгирования |
| **Job** | Задачи с завершением (разовые) | Миграции БД, обработка данных |

---

</details>

<details>
<summary><b>📊Ключевые выводы</b></summary>

---

## Основные принципы ReplicaSet

1. **📌 Обеспечивает стабильность** - поддерживает заданное количество Pod'ов
2. **📌 Автоматическое восстановление** - пересоздает упавшие Pod'ы
3. **📌 Расширенный селектор** - более гибкий чем у Replication Controller
4. **📌 Горизонтальное масштабирование** - легко изменить количество реплик
5. **📌 Самостоятельное использование редко** - обычно управляется через Deployment

## Best Practices

```
✅ Всегда используйте ReplicaSet вместо ReplicationController
✅ Убедитесь, что selector.matchLabels совпадает с template.metadata.labels
✅ Используйте осмысленные метки для организации
✅ Начинайте с 2-3 реплик для production
✅ Храните манифесты в системе контроля версий
```

> 💡 **Практический совет:** Используйте Deployment вместо прямого создания ReplicaSet'ов. Deployment предоставляет дополнительный функционал (историю изменений, откат, плавные обновления) и автоматически управляет ReplicaSet'ами.

---

</details>