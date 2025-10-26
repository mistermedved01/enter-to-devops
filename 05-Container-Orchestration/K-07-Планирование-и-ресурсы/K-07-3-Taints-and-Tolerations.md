[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [🎯 K-07-Планирование-и-ресурсы](../../README.md#-k-07-планирование-и-ресурсы)

---

# 🚫K-07-3-Taints-and-Tolerations
>Taints и Tolerations — механизм ограничения размещения Pod'ов на узлах через "заражение" узлов и "толерантность" Pod'ов

---

<details>
<summary><b>🔍Что такое Taints и Tolerations?</b></summary>

---

## Концепция через аналогию

**Taints** - это "заражение" узла специальным "репеллентом", который отталкивает Pod'ы.

**Tolerations** - это "толерантность" Pod'а к определенному "заражению", позволяющая ему размещаться на "зараженном" узле.

### Аналогия с комарами и пчеловодом

Представьте пчеловода **Фея**, которого опрыскали репеллентом:

```
🐝 Пчеловод Фей (Node)
├── 🚫 Репеллент "green" (Taint)
└── ☁️ Ароматное облако вокруг него

🦟 Комары (обычные Pod'ы)
├── ❌ Не переносят запах "green" (No Tolerations)
└── 🏃 Улетают прочь

🐝 Пчелы (специальные Pod'ы)  
├── ✅ Не боятся запаха "green" (Tolerations)
└── 🏠 Могут подлететь к Фею
```

**В Kubernetes:**
- **Node** = Пчеловод Фей
- **Taint** = Репеллент "green"
- **Pod'ы** = Комары и пчелы
- **Tolerations** = Устойчивость к запаху

---

## Зачем нужны Taints и Tolerations?

**Проблема:** Как выделить определенные узлы для специальных приложений?

**Примеры использования:**
- 🖥️ **GPU-узлы** - только для ML/AI приложений
- 💾 **SSD-узлы** - только для баз данных
- 🌐 **Edge-узлы** - только для edge-приложений
- 🔒 **Изолированные узлы** - только для критичных приложений

**Без Taints:**
```
┌─────────┐ ┌─────────┐ ┌─────────┐
│ Node 01 │ │ Node 02 │ │ Node 03 │
│ (GPU)   │ │ (SSD)   │ │ (CPU)   │
├─────────┤ ├─────────┤ ├─────────┤
│ Pod A   │ │ Pod B   │ │ Pod C   │
│ Pod D   │ │ Pod E   │ │ Pod F   │
│ Pod G   │ │ Pod H   │ │ Pod I   │
└─────────┘ └─────────┘ └─────────┘
❌ Scheduler размещает случайно
```

**С Taints:**
```
┌─────────┐ ┌─────────┐ ┌─────────┐
│ Node 01 │ │ Node 02 │ │ Node 03 │
│ (GPU)   │ │ (SSD)   │ │ (CPU)   │
│ Taint:  │ │ Taint:  │ │ No      │
│ gpu=true│ │ ssd=true│ │ Taints  │
├─────────┤ ├─────────┤ ├─────────┤
│ ML Pod  │ │ DB Pod  │ │ Web Pod │
│ (toler.)│ │ (toler.)│ │ (any)   │
└─────────┘ └─────────┘ └─────────┘
✅ Контролируемое размещение
```

---

</details>

<details>
<summary><b>🎯Как работают Taints?</b></summary>

---

## Установка Taint на узел

### Команда kubectl taint

```bash
# Синтаксис
kubectl taint nodes <node-name> <key>=<value>:<effect>

# Примеры
kubectl taint nodes node01 app=green:NoSchedule
kubectl taint nodes gpu-node01 gpu=true:NoSchedule
kubectl taint nodes ssd-node02 storage=ssd:NoSchedule
```

### Структура Taint

```
<key>=<value>:<effect>
     ↓        ↓      ↓
   ключ    значение  эффект
```

**Примеры:**
- `app=green:NoSchedule`
- `gpu=true:NoSchedule` 
- `storage=ssd:PreferNoSchedule`
- `environment=prod:NoExecute`

---

## Эффекты Taint

### 1. NoSchedule - "Не планируй новые Pod'ы"
```bash
kubectl taint nodes node01 app=green:NoSchedule
```

**Что происходит:**
- ❌ **Новые Pod'ы БЕЗ toleration** → НЕ назначаются на узел
- ✅ **Новые Pod'ы С toleration** → МОГУТ быть назначены на узел  
- 🔄 **Существующие Pod'ы** → остаются на узле (не трогаем)

**Пример:**
```
До taint:
┌─────────┐ ┌─────────┐
│ Node 01 │ │ Node 02 │
│ Pod A   │ │ Pod B   │
│ Pod C   │ │         │
└─────────┘ └─────────┘

После taint app=green:NoSchedule:
┌─────────┐ ┌─────────┐
│ Node 01 │ │ Node 02 │
│ Pod A   │ │ Pod B   │ ← Новый Pod D
│ Pod C   │ │ Pod D   │   (без toleration)
└─────────┘ └─────────┘
✅ A, C остались
❌ D не попал на Node 01
```

**Используется когда:** Хотите выделить узел для специальных приложений

### 2. PreferNoSchedule - "Попробуй избежать, но если нужно - назначь"
```bash
kubectl taint nodes node01 app=green:PreferNoSchedule
```

**Что происходит:**
- ⚠️ **Scheduler ПЫТАЕТСЯ** избежать назначения Pod'ов без toleration
- 🔄 **Если других узлов нет** → назначит на этот узел
- 🔄 **Существующие Pod'ы** → остаются на узле

**Пример:**
```
Узлы: Node 01 (с taint), Node 02 (занят), Node 03 (занят)

Новый Pod без toleration:
┌─────────┐ ┌─────────┐ ┌─────────┐
│ Node 01 │ │ Node 02 │ │ Node 03 │
│ (taint) │ │ (занят) │ │ (занят) │
│         │ │ Pod B   │ │ Pod C   │
└─────────┘ └─────────┘ └─────────┘
     ↓
┌─────────┐ ┌─────────┐ ┌─────────┐
│ Node 01 │ │ Node 02 │ │ Node 03 │
│ (taint) │ │ (занят) │ │ (занят) │
│ Pod D   │ │ Pod B   │ │ Pod C   │
└─────────┘ └─────────┘ └─────────┘
⚠️ Pod D назначен на Node 01 (других вариантов нет)
```

**Используется когда:** Мягкое ограничение, но не критично

### 3. NoExecute - "Удали неподходящие Pod'ы СЕЙЧАС!"
```bash
kubectl taint nodes node01 app=green:NoExecute
```

**Что происходит:**
- ❌ **Новые Pod'ы БЕЗ toleration** → НЕ назначаются на узел
- 🗑️ **Существующие Pod'ы БЕЗ toleration** → УДАЛЯЮТСЯ с узла
- ✅ **Pod'ы С toleration** → остаются и могут быть назначены

**Пример:**
```
До taint:
┌─────────┐ ┌─────────┐
│ Node 01 │ │ Node 02 │
│ Pod A   │ │ Pod B   │
│ Pod C   │ │         │
└─────────┘ └─────────┘

После taint app=green:NoExecute:
┌─────────┐ ┌─────────┐
│ Node 01 │ │ Node 02 │
│         │ │ Pod B   │
│         │ │ Pod A   │ ← Переехал
│         │ │ Pod C   │ ← Переехал
└─────────┘ └─────────┘
🗑️ A, C удалены с Node 01
🔄 A, C пересозданы на Node 02
```

**Используется когда:** Критичное ограничение, нужно освободить узел

---

## 📊 Сравнительная таблица эффектов

| Эффект | Новые Pod'ы без toleration | Существующие Pod'ы без toleration | Когда использовать |
|--------|---------------------------|-----------------------------------|-------------------|
| **NoSchedule** | ❌ НЕ назначаются | ✅ Остаются | Выделить узел для специальных приложений |
| **PreferNoSchedule** | ⚠️ Пытается избежать, но может назначить | ✅ Остаются | Мягкое ограничение |
| **NoExecute** | ❌ НЕ назначаются | 🗑️ УДАЛЯЮТСЯ | Критичное ограничение, освободить узел |

> 💡 **Ключевое различие:** NoSchedule и PreferNoSchedule работают только с **новыми** Pod'ами, а NoExecute работает и с **новыми**, и с **существующими** Pod'ами.

---

</details>

<details>
<summary><b>🛡️Как работают Tolerations?</b></summary>

---

## Создание Tolerations в Pod

### Структура Tolerations

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: special-pod
spec:
  tolerations:
  - key: "app"              # Ключ taint
    operator: "Equal"       # Оператор сравнения
    value: "green"          # Значение taint
    effect: "NoSchedule"    # Эффект taint
  containers:
  - name: app
    image: nginx:latest
```

### Операторы сравнения

#### 1. Equal (по умолчанию)
```yaml
tolerations:
- key: "app"
  operator: "Equal"
  value: "green"
  effect: "NoSchedule"
```
**Означает:** `app=green:NoSchedule`

#### 2. Exists
```yaml
tolerations:
- key: "app"
  operator: "Exists"
  effect: "NoSchedule"
```
**Означает:** Любое значение ключа `app` с эффектом `NoSchedule`

### Примеры Tolerations

#### Пример 1: Точное соответствие
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  tolerations:
  - key: "gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
  containers:
  - name: ml-app
    image: tensorflow/tensorflow:latest-gpu
```

#### Пример 2: Любое значение ключа
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: flexible-pod
spec:
  tolerations:
  - key: "environment"
    operator: "Exists"
    effect: "NoSchedule"
  containers:
  - name: app
    image: nginx:latest
```

#### Пример 3: Несколько Tolerations
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-tolerations-pod
spec:
  tolerations:
  - key: "gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
  - key: "storage"
    operator: "Equal"
    value: "ssd"
    effect: "PreferNoSchedule"
  containers:
  - name: app
    image: nginx:latest
```

---

</details>

<details>
<summary><b>📋Практические примеры</b></summary>

---

## Пример 1: Выделение GPU-узла

### Шаг 1: Установить Taint на GPU-узел

```bash
# Установить taint на GPU-узел
kubectl taint nodes gpu-node01 gpu=true:NoSchedule

# Проверить taint
kubectl describe node gpu-node01 | grep Taints
# Taints: gpu=true:NoSchedule
```

### Шаг 2: Создать обычный Pod (не будет назначен)

```yaml
# normal-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: normal-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
```

```bash
kubectl apply -f normal-pod.yaml

# Pod останется в Pending
kubectl get pods
# NAME        READY   STATUS    RESTARTS   AGE
# normal-pod  0/1     Pending   0          10s

# Проверить события
kubectl describe pod normal-pod | grep -A 5 Events
# Warning  FailedScheduling  pod/normal-pod 0/1 nodes are available: 1 node(s) had taint {gpu: true}, that the pod didn't tolerate.
```

### Шаг 3: Создать Pod с Tolerations

```yaml
# gpu-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  tolerations:
  - key: "gpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
  containers:
  - name: ml-app
    image: tensorflow/tensorflow:latest-gpu
```

```bash
kubectl apply -f gpu-pod.yaml

# Pod успешно назначен на GPU-узел
kubectl get pods -o wide
# NAME     READY   STATUS    RESTARTS   AGE   NODE
# gpu-pod  1/1     Running   0          5s    gpu-node01
```

---

## Пример 2: Эффект NoExecute

### Шаг 1: Создать Pod'ы на узле

```yaml
# app-pods.yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod-1
spec:
  containers:
  - name: nginx
    image: nginx:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: app-pod-2
spec:
  containers:
  - name: nginx
    image: nginx:latest
---
apiVersion: v1
kind: Pod
metadata:
  name: special-pod
spec:
  tolerations:
  - key: "maintenance"
    operator: "Equal"
    value: "true"
    effect: "NoExecute"
  containers:
  - name: nginx
    image: nginx:latest
```

```bash
kubectl apply -f app-pods.yaml

# Все Pod'ы запущены
kubectl get pods -o wide
# NAME         READY   STATUS    RESTARTS   AGE   NODE
# app-pod-1    1/1     Running   0          10s   node01
# app-pod-2    1/1     Running   0          10s   node01
# special-pod  1/1     Running   0          10s   node01
```

### Шаг 2: Установить NoExecute Taint

```bash
# Установить taint с NoExecute
kubectl taint nodes node01 maintenance=true:NoExecute

# Проверить результат
kubectl get pods -o wide
# NAME         READY   STATUS    RESTARTS   AGE   NODE
# special-pod  1/1     Running   0          30s   node01
# app-pod-1    0/1     Pending   0          30s   <none>
# app-pod-2    0/1     Pending   0          30s   <none>
```

**Что произошло:**
- ✅ `special-pod` остался (имеет toleration)
- 🗑️ `app-pod-1` и `app-pod-2` удалены (нет toleration)
- 🔄 Удаленные Pod'ы пересоздаются на других узлах

---

## Пример 3: Master-узел

### Проверить Taint на Master

```bash
# Посмотреть taint на master-узле
kubectl describe node master-node | grep Taints
# Taints: node-role.kubernetes.io/control-plane:NoSchedule

# Или через get
kubectl get nodes master-node -o jsonpath='{.spec.taints}'
# [{"effect":"NoSchedule","key":"node-role.kubernetes.io/control-plane"}]
```

### Создать Pod для Master (не рекомендуется!)

```yaml
# master-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: master-pod
spec:
  tolerations:
  - key: "node-role.kubernetes.io/control-plane"
    operator: "Exists"
    effect: "NoSchedule"
  containers:
  - name: nginx
    image: nginx:latest
```

```bash
kubectl apply -f master-pod.yaml

# Pod будет назначен на master (НЕ рекомендуется!)
kubectl get pods -o wide
# NAME        READY   STATUS    RESTARTS   AGE   NODE
# master-pod  1/1     Running   0          5s    master-node
```

> ⚠️ **Важно:** Не размещайте рабочие нагрузки на master-узлах в production!

---

</details>

<details>
<summary><b>🔧Управление Taints</b></summary>

---

## Просмотр Taints

### Посмотреть все Taints на узле

```bash
# Детальная информация
kubectl describe node node01 | grep -A 10 Taints

# Только Taints
kubectl get node node01 -o jsonpath='{.spec.taints}'

# Через yaml
kubectl get node node01 -o yaml | grep -A 5 taints
```

### Посмотреть все узлы с Taints

```bash
# Все узлы с их Taints
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Только узлы с Taints
kubectl get nodes -o json | jq '.items[] | select(.spec.taints != null) | {name: .metadata.name, taints: .spec.taints}'
```

---

## Удаление Taints

### Удалить конкретный Taint

```bash
# Синтаксис (добавить минус в конце)
kubectl taint nodes <node-name> <key>=<value>:<effect>-

# Примеры
kubectl taint nodes node01 app=green:NoSchedule-
kubectl taint nodes gpu-node01 gpu=true:NoSchedule-
```

### Удалить все Taints

```bash
# Удалить все Taints с узла
kubectl patch node node01 -p '{"spec":{"taints":[]}}'
```

---

## Изменение Taints

### Изменить эффект Taint

```bash
# Сначала удалить старый
kubectl taint nodes node01 app=green:NoSchedule-

# Затем добавить новый
kubectl taint nodes node01 app=green:NoExecute
```

### Изменить значение Taint

```bash
# Удалить старый
kubectl taint nodes node01 app=green:NoSchedule-

# Добавить новый
kubectl taint nodes node01 app=blue:NoSchedule
```

---

</details>

<details>
<summary><b>⚠️Важные ограничения</b></summary>

---

## Что Taints НЕ делают

### ❌ НЕ гарантируют размещение

**Taints и Tolerations НЕ говорят:** "Размести этот Pod на этом узле"

**Они говорят:** "Этот узел принимает только Pod'ы с определенными tolerations"

### Пример проблемы

```bash
# Узел с taint
kubectl taint nodes node01 app=green:NoSchedule

# Pod с toleration
kubectl apply -f green-pod.yaml  # С toleration для app=green
```

**Результат:** Pod МОЖЕТ быть размещен на node01, но НЕ ОБЯЗАН быть там!

Scheduler может выбрать node01, node02 или node03 - в зависимости от других факторов.

---

## Что использовать для принудительного размещения?

### Node Affinity (следующая тема)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: affinity-pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: app
            operator: In
            values: ["green"]
  containers:
  - name: nginx
    image: nginx:latest
```

**Node Affinity говорит:** "ОБЯЗАТЕЛЬНО размести на узле с меткой app=green"

---

## Схема различий

```
┌─────────────────────────────────────┐
│         Taints & Tolerations        │
│                                     │
│  "Этот узел принимает только       │
│   Pod'ы с определенными            │
│   tolerations"                     │
│                                     │
│  ❌ НЕ гарантирует размещение      │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│           Node Affinity             │
│                                     │
│  "ОБЯЗАТЕЛЬНО размести на узле     │
│   с определенными метками"         │
│                                     │
│  ✅ ГАРАНТИРУЕТ размещение         │
└─────────────────────────────────────┘
```

---

</details>

<details>
<summary><b>📚Резюме</b></summary>

---

## Ключевые моменты

1. **Taints** - "заражение" узла, отталкивает Pod'ы без tolerations
2. **Tolerations** - "толерантность" Pod'а к taint, позволяет размещаться на узле
3. **Три эффекта:** NoSchedule, PreferNoSchedule, NoExecute
4. **НЕ гарантируют** размещение - только ограничивают

## Команды для работы

```bash
# Установить taint
kubectl taint nodes <node> <key>=<value>:<effect>

# Удалить taint
kubectl taint nodes <node> <key>=<value>:<effect>-

# Посмотреть taints
kubectl describe node <node> | grep Taints

# Создать Pod с tolerations
kubectl apply -f pod-with-tolerations.yaml
```

## Лучшие практики

### ✅ Хорошие практики
- Используйте осмысленные ключи (`gpu`, `storage`, `environment`)
- PreferNoSchedule для мягких ограничений
- NoExecute только когда критично
- Не размещайте рабочие нагрузки на master

### ❌ Избегайте
- Слишком много taints на одном узле
- NoExecute без предупреждения
- Размещение на master-узлах в production

## Что дальше?

Taints и Tolerations - основа для:
- **Node Affinity** - принудительное размещение на узлах
- **Pod Affinity** - размещение Pod'ов рядом друг с другом
- **Resource Management** - управление ресурсами узлов

> 💡 **Вывод:** Taints и Tolerations - это "стражники" узлов. Они не говорят куда идти, но говорят куда НЕ идти!

---

</details>
