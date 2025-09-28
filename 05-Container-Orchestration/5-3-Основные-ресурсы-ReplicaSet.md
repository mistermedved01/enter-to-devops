# 🔹5-3-Основные-ресурсы-ReplicaSet

`ReplicaSet` - управление репликами Pod'ов

<details>
<summary><b>🔍 Что такое ReplicaSet?</b></summary>

---

ReplicaSet гарантирует, что **определенное количество экземпляров Pod'ов** будет запущено в кластере Kubernetes в любой момент времени.

> ⚠️ **Важное замечание:** В современных Kubernetes рекомендуется использовать **Deployment**, который управляет ReplicaSet'ами автоматически.

</details>

<details>
<summary><b>🆚ReplicaSet vs Replication Controller</b></summary>

---

ReplicaSet - это следующее поколение Replication Controller. Единственное отличие - **поддержка расширенного селектора**:

- **ReplicaSet**: поддерживает множественный выбор в селекторе
- **Replication Controller**: только выбор на основе равенства

---

</details>

<details>
<summary><b>📋Структура ReplicaSet манифеста</b></summary>

---

```yaml
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
- **`.spec.template.spec.restartPolicy`** - только `Always` (значение по умолчанию)

### Ключевые параметры:

- **`.spec.selector`** - селектор меток для управления Pod'ами
- **`.spec.replicas`** - количество экземпляров Pod'ов (по умолчанию 1)

---

</details>

<details>
<summary><b>🎯Как работает селектор?</b></summary>

---

ReplicaSet управляет **всеми Pod'ами**, чьи метки соответствуют селектору, независимо от того:
- Созданы ли они самим ReplicaSet
- Созданы другим процессом (Deployment)
- Созданы администратором вручную

Это позволяет изменять ReplicaSet, не затрагивая запущенные Pod'ы.

---

</details>

<details>
<summary><b>🛠️Практическая работа</b></summary>

---

### Создание ReplicaSet

```bash
kubectl create -f frontend.yaml
```

### Просмотр состояния

```bash
kubectl describe rs/frontend
```

**Пример вывода:**
```bash
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

### Удаление ReplicaSet

**Стандартное удаление (с Pod'ами):**
```bash
kubectl delete rs/frontend
```

*Kubectl автоматически:*
1. *Масштабирует до 0 реплик*
2. *Удаляет все Pod'ы*
3. *Удаляет ReplicaSet*

**Удаление только ReplicaSet (Pod'ы остаются):**
```bash
kubectl delete rs/frontend --cascade=false
```

### Изоляция Pod'а от ReplicaSet

```bash
kubectl label pod frontend-xyz tier=debug --overwrite
```

ReplicaSet создаст новый Pod взамен "отвязанного".

---

</details>

<details>
<summary><b>📈Масштабирование</b></summary>

---

### Ручное масштабирование

```bash
# Через редактирование манифеста
kubectl apply -f frontend.yaml

# Императивной командой
kubectl scale rs/frontend --replicas=5
```

### Автоматическое масштабирование (HPA)

```yaml
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
| **Job** | Задачи с завершением (разовые) | Миграции БД, обработка данных |
| **DaemonSet** | По одному Pod'у на каждой ноде | Агенты мониторинга, логгирования |

---

</details>

<details>
<summary><b>📊Ключевые выводы</b></summary>

---

1. **ReplicaSet обеспечивает стабильность** - поддерживает заданное количество Pod'ов
2. **Расширенный селектор** - более гибкий чем у Replication Controller
3. **Самостоятельное использование редко** - обычно управляется через Deployment
4. **Автомасштабирование** - поддерживает Horizontal Pod Autoscaler
5. **Гибкое управление** - можно изолировать Pod'ы, каскадное удаление

> 💡 **Практический совет:** Используйте Deployment вместо прямого создания ReplicaSet'ов. Deployment предоставляет дополнительный функционал (историю изменений, откат, плавные обновления) и автоматически управляет ReplicaSet'ами.

---

</details>