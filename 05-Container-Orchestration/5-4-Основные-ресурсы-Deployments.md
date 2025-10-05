# 🚀5-4-Основные-ресурсы-Deployment
>Deployment управляет ReplicaSet’ами и Pod’ами, позволяя безопасно обновлять приложение, масштабировать его и при необходимости быстро откатывать изменения.

<details>
<summary><b>🔍Что такое Deployment?</b></summary>

---

Deployment предоставляет **декларативное обновление** для Pod'ов и ReplicaSets. Достаточно описать желаемое состояние, а контроллер развертывания изменит текущее состояние на желаемое.

**Ключевое преимущество:** Не нужно беспокоиться об управлении ReplicaSet'ами - Deployment все сделает автоматически.

---

</details>

<details>
<summary><b>📋Структура манифеста Deployment</b></summary>

---

```yaml
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

- **`.spec.template`** - шаблон Pod'а (аналогичен Pod без apiVersion/kind)
- **`.spec.template.metadata.labels`** - метки Pod'а
- **`.spec.template.spec.restartPolicy`** - только `Always`

### Основные параметры:

- **`.spec.replicas`** - количество экземпляров Pod'ов (по умолчанию 1)
- **`.spec.selector`** - должен соответствовать `.spec.template.metadata.labels`

---

</details>

<details>
<summary><b>🔄Стратегии обновления</b></summary>

---

### Recreate
```yaml
strategy:
  type: Recreate
```

- Удаляет все старые Pod'ы перед запуском новых
- Короткий простой приложения

### RollingUpdate (по умолчанию)
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 1
    maxSurge: 1
```

- **`maxUnavailable`** - максимальное количество недоступных Pod'ов (по умолчанию 25%)
- **`maxSurge`** - максимальное количество Pod'ов сверх желаемого (по умолчанию 25%)
- Плавное обновление без простоя

---

</details>

<details>
<summary><b>🛠️Практическая работа с Deployment</b></summary>

---

### Создание Deployment

```bash
kubectl create -f nginx-deployment.yaml --record
```

> 💡 **Важно:** Параметр `--record` сохраняет историю изменений

### Мониторинг состояния

```bash
kubectl get deployments
```

**Пример вывода:**
```bash
NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3         3         3            3           18s
```

- **DESIRED** - желаемое количество Pod'ов
- **CURRENT** - текущее количество Pod'ов
- **UP-TO-DATE** - количество обновленных Pod'ов
- **AVAILABLE** - количество доступных Pod'ов

### Детальный мониторинг

```bash
kubectl rollout status deployment/nginx-deployment
kubectl get rs
kubectl get pods --show-labels
```

**Пример вывода get rs:**
```bash
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-2035384211   3         3         3       18s
```

---

</details>

<details>
<summary><b>🔄Методы обновления Deployment</b></summary>

---

### 1. Командой set image (быстро)
```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1
```

### 2. Редактирование в реальном времени
```bash
kubectl edit deployment/nginx-deployment
```

### 3. Через файл манифеста (рекомендуется)
```bash
nano nginx-deployment.yaml
kubectl apply -f nginx-deployment.yaml
```

---

</details>

<details>
<summary><b>📜История изменений и откат</b></summary>

---

### Просмотр истории ревизий

```bash
kubectl rollout history deployment/nginx-deployment
```

**Вывод:**
```bash
REVISION    CHANGE-CAUSE
1           kubectl create -f nginx-deployment.yaml --record
2           kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1
3           kubectl set image deployment/nginx-deployment nginx=nginx:1.91
```

### Детали ревизии

```bash
kubectl rollout history deployment/nginx-deployment --revision=2
```

### Откат изменений

**На предыдущую версию:**
```bash
kubectl rollout undo deployment/nginx-deployment
```

**На конкретную ревизию:**
```bash
kubectl rollout undo deployment/nginx-deployment --to-revision=2
```

---

</details>

<details>
<summary><b>⚠️Пример сценария с ошибкой</b></summary>

---

### Ошибочное обновление
```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.91
```

### Проверка состояния
```bash
kubectl rollout status deployments nginx-deployment
kubectl get rs
kubectl get pods
```

**Вывод при ошибке:**
```bash
NAME                                READY     STATUS             RESTARTS   AGE
nginx-deployment-3066724191-08mng   0/1       ImagePullBackOff   0          6s
```

### Откат на рабочую версию
```bash
kubectl rollout undo deployment/nginx-deployment --to-revision=2
```

---

</details>

<details>
<summary><b>📈Масштабирование</b></summary>

---

### Ручное масштабирование
```bash
kubectl scale deployment nginx-deployment --replicas=10
```

### Автоматическое масштабирование (HPA)
```bash
kubectl autoscale deployment nginx-deployment --min=10 --max=15 --cpu-percent=80
```

---

</details>

<details>
<summary><b>🔍Детальная информация о Deployment</b></summary>

---

```bash
kubectl describe deployments
```

**Ключевые секции вывода:**
```bash
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

1. **Всегда используйте `--record`** для сохранения истории изменений
2. **Предпочитайте файлы манифестов** прямым командам
3. **Тестируйте стратегии обновления** перед продакшеном
4. **Используйте readinessProbe** для определения готовности Pod'ов
5. **Настраивайте ресурсные ограничения** для контейнеров

---

</details>

<details>
<summary><b>✅Ключевые преимущества</b></summary>

---

✅ **Декларативное управление** - описываем "что", а не "как"  
✅ **Плавные обновления** - без простоя приложения  
✅ **История изменений** - легкий откат при проблемах  
✅ **Автоматическое восстановление** - самоподдерживающееся состояние  
✅ **Интеграция с HPA** - автоматическое масштабирование  

> 💡 **Итог:** Deployment - это основной и рекомендуемый способ управления приложениями в Kubernetes. Используйте его вместо прямого создания Pod'ов или ReplicaSet'ов.

---

</details>