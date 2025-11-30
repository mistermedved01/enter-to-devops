[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [🌱 K-04-Ресурсы-Kubernetes](../../README.md#-k-04-ресурсы-kubernetes)

# 🚀K-04-4-Controller-Deployments
>Deployment - высокоуровневый контроллер для управления ReplicaSet'ами, обеспечивает безопасные обновления, масштабирование и откаты приложений

<details>
<summary><b>🔍Что такое Deployment?</b></summary>

---

Deployment предоставляет **декларативное обновление** для Pod'ов и ReplicaSets. Достаточно описать желаемое состояние, а контроллер развертывания изменит текущее состояние на желаемое.

```
# Иерархия: Deployment → ReplicaSet → Pods
Deployment (myapp-deployment)
        ↓
    ReplicaSet (myapp-deployment-12345)  
        ↓
    Pods (myapp-deployment-12345-abc, xyz, def)
```

**Ключевое преимущество:** Не нужно беспокоиться об управлении ReplicaSet'ами - Deployment все сделает автоматически.

---

</details>

<details>
<summary><b>📋Структура манифеста Deployment</b></summary>

---

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 25%
      maxSurge: 25%
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

### Обязательные поля:

- **`.spec.selector`** - должен соответствовать `.spec.template.metadata.labels`
- **`.spec.template`** - шаблон Pod'а (аналогичен Pod без apiVersion/kind)
- **`.spec.template.metadata.labels`** - метки Pod'а

### Основные параметры:

- **`.spec.replicas`** - количество экземпляров Pod'ов (по умолчанию 1)
- **`.spec.strategy`** - стратегия обновления (RollingUpdate/Recreate)

---

</details>

<details>
<summary><b>🔄Стратегии обновления</b></summary>

---

### Recreate
```
strategy:
  type: Recreate
```

- Удаляет все старые Pod'ы перед запуском новых
- **Короткий простой** приложения
- Подходит для stateful приложений

### RollingUpdate (по умолчанию)
```
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 1
    maxSurge: 1
```

```
# Процесс Rolling Update:
[Pod A-v1] [Pod B-v1] [Pod C-v1]    # Начальное состояние
    ↓
[Pod A-v1] [Pod B-v1] [Pod C-v2]    # Шаг 1: Обновлен один Pod
    ↓  
[Pod A-v1] [Pod B-v2] [Pod C-v2]    # Шаг 2: Обновлен второй Pod
    ↓
[Pod A-v2] [Pod B-v2] [Pod C-v2]    # Шаг 3: Все Pod'ы обновлены
```

- **`maxUnavailable`** - максимальное количество недоступных Pod'ов (по умолчанию 25%)
- **`maxSurge`** - максимальное количество Pod'ов сверх желаемого (по умолчанию 25%)
- **Плавное обновление без простоя**

---

</details>

<details>
<summary><b>🛠️Практическая работа с Deployment</b></summary>

---

### Создание Deployment

```
# Создать Deployment с записью истории
kubectl create -f nginx-deployment.yaml --record

# Или применить (более современно)
kubectl apply -f nginx-deployment.yaml
```

> 💡 **Важно:** Параметр `--record` сохраняет историю изменений

### Мониторинг состояния

```
# Просмотреть Deployments
kubectl get deployments
kubectl get deploy               # Сокращенная команда

# Детальный статус
kubectl rollout status deployment/nginx-deployment
```

**Пример вывода get deployments:**
```bash
NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3         3         3            3           18s
```

- **DESIRED** - желаемое количество Pod'ов
- **CURRENT** - текущее количество Pod'ов
- **UP-TO-DATE** - количество обновленных Pod'ов
- **AVAILABLE** - количество доступных Pod'ов

### Просмотр связанных объектов

```bash
# Связанные ReplicaSet
kubectl get rs

# Связанные Pod'ы
kubectl get pods --show-labels

# Все объекты разом
kubectl get all
```

**Пример вывода get rs:**
```
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-2035384211   3         3         3       18s
```

---

</details>

<details>
<summary><b>🔄Методы обновления Deployment</b></summary>

---

### 1. Командой set image (быстро)
```
kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1
```

### 2. Редактирование в реальном времени
```
kubectl edit deployment/nginx-deployment
```

### 3. Через файл манифеста (рекомендуется)
```
# Изменить image в deployment.yaml
kubectl apply -f nginx-deployment.yaml
```

### 4. Приостановка и возобновление
```
# Приостановить для нескольких изменений
kubectl rollout pause deployment/nginx-deployment

# Внести изменения
kubectl set image deployment/nginx-deployment nginx=nginx:1.21
kubectl set resources deployment/nginx-deployment -c=nginx --limits=cpu=200m,memory=512Mi

# Возобновить
kubectl rollout resume deployment/nginx-deployment
```

---

</details>

<details>
<summary><b>📜История изменений и откат</b></summary>

---

### Просмотр истории ревизий

```
# История изменений
kubectl rollout history deployment/nginx-deployment

# Детали конкретной ревизии
kubectl rollout history deployment/nginx-deployment --revision=2
```

**Вывод истории:**
```
REVISION    CHANGE-CAUSE
1           kubectl create -f nginx-deployment.yaml --record
2           kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1
3           kubectl set image deployment/nginx-deployment nginx=nginx:1.91
```

### Откат изменений

```
# На предыдущую версию
kubectl rollout undo deployment/nginx-deployment

# На конкретную ревизию
kubectl rollout undo deployment/nginx-deployment --to-revision=2

# Принудительный откат
kubectl rollout undo deployment/nginx-deployment --force
```

---

</details>

<details>
<summary><b>⚠️Пример сценария с ошибкой</b></summary>

---

### Ошибочное обновление
```
kubectl set image deployment/nginx-deployment nginx=nginx:1.91
```

### Проверка состояния
```
kubectl rollout status deployment nginx-deployment
kubectl get pods
```

**Вывод при ошибке:**
```
NAME                                READY     STATUS             RESTARTS   AGE
nginx-deployment-3066724191-08mng   0/1       ImagePullBackOff   0          6s
```

### Откат на рабочую версию
```
kubectl rollout undo deployment/nginx-deployment --to-revision=2
```

---

</details>

<details>
<summary><b>📈Масштабирование</b></summary>

---

### Ручное масштабирование
```
kubectl scale deployment nginx-deployment --replicas=10
```

### Автоматическое масштабирование (HPA)
```
kubectl autoscale deployment nginx-deployment --min=10 --max=15 --cpu-percent=80
```

---

</details>

<details>
<summary><b>🔍Детальная информация о Deployment</b></summary>

---

```
kubectl describe deployment nginx-deployment
```

**Ключевые секции вывода:**
```
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
RollingUpdateStrategy:  25% max unavailable, 25% max surge
NewReplicaSet:   nginx-deployment-1564180365 (3/3 replicas created)
Events:
  Normal  ScalingReplicaSet  24s  deployment-controller  Scaled up replica set to 1
  Normal  ScalingReplicaSet  22s  deployment-controller  Scaled down replica set to 2
```

---

</details>

<details>
<summary><b>💡Best Practices</b></summary>

---

```
✅ Всегда используйте `--record` для сохранения истории изменений
✅ Предпочитайте файлы манифестов прямым командам
✅ Тестируйте стратегии обновления перед продакшеном
✅ Используйте readinessProbe для определения готовности Pod'ов
✅ Настраивайте ресурсные ограничения для контейнеров
✅ Начинайте с 2-3 реплик для production
✅ Мониторьте статус rollout'ов в production
```

---

</details>

---

## Резюме

✅ **Deployment** — высокоуровневый контроллер для управления ReplicaSet'ами и Pod'ами

✅ **Ключевые преимущества:**
- Декларативное управление — описываем "что", а не "как"
- Плавные обновления — без простоя приложения
- История изменений — легкий откат при проблемах
- Автоматическое восстановление — самоподдерживающееся состояние
- Интеграция с HPA — автоматическое масштабирование
- Контроль развертывания — приостановка и возобновление

✅ **Стратегии обновления:**
- `RollingUpdate` (по умолчанию) — плавное обновление без простоя
- `Recreate` — удаление всех старых Pod'ов перед запуском новых

✅ **Best Practices:**
- Всегда используйте `--record` для сохранения истории изменений
- Предпочитайте файлы манифестов прямым командам
- Тестируйте стратегии обновления перед продакшеном
- Используйте readinessProbe для определения готовности Pod'ов
- Настраивайте ресурсные ограничения для контейнеров

> 💡 **Итог:** Deployment - это основной и рекомендуемый способ управления приложениями в Kubernetes. Используйте его вместо прямого создания Pod'ов или ReplicaSet'ов.

---