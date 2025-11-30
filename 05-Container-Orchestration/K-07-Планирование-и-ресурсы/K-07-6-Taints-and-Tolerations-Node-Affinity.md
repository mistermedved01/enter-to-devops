[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [🎯 K-07-Планирование-и-ресурсы](../../README.md#-k-07-планирование-и-ресурсы)

---

# 🔗K-07-6-Taints-and-Tolerations-Node-Affinity
>Комбинация Taints & Tolerations и Node Affinity — полное выделение узлов для определенных нагрузок через комбинирование механизмов ограничения и размещения

---

<details>
<summary><b>🎯Задача: выделение узлов для определенных нагрузок</b></summary>

---

## Проблема

У нас есть кластер Kubernetes с тремя узлами и тремя Pod'ами:

```
┌─────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                   │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Синий узел          Зеленый узел       Красный узел    │
│  ┌─────────┐         ┌─────────┐        ┌─────────┐    │
│  │ Node 1  │         │ Node 2  │         │ Node 3  │    │
│  │ (синий) │         │ (зеленый)│        │ (красный)│   │
│  └─────────┘         └─────────┘        └─────────┘    │
│                                                          │
│  Синий Pod           Зеленый Pod        Красный Pod    │
│  ┌─────────┐         ┌─────────┐        ┌─────────┐    │
│  │ Pod 1   │         │ Pod 2  │         │ Pod 3  │    │
│  │ (синий) │         │ (зеленый)│        │ (красный)│   │
│  └─────────┘         └─────────┘        └─────────┘    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

**Конечная цель:**
- ✅ Синий Pod → Синий узел
- ✅ Зеленый Pod → Зеленый узел
- ✅ Красный Pod → Красный узел

**Дополнительные требования:**
- ❌ Другие Pod'ы (из других проектов) НЕ должны размещаться на наших узлах
- ✅ Наши Pod'ы должны размещаться только на своих узлах

**Контекст:**
- Кластер используется совместно с другими группами пользователей
- В кластере есть другие Pod'ы и другие узлы
- Нужно полностью изолировать наши узлы для наших нагрузок

---

</details>

<details>
<summary><b>❌Попытка 1: Только Taints & Tolerations</b></summary>

---

## Решение через Taints & Tolerations

### Шаг 1: Применяем Taints на узлы

```bash
# Помечаем узлы соответствующими цветами через Taints
kubectl taint node node1 color=blue:NoSchedule
kubectl taint node node2 color=green:NoSchedule
kubectl taint node node3 color=red:NoSchedule
```

**Результат:**
- Синий узел имеет Taint `color=blue:NoSchedule`
- Зеленый узел имеет Taint `color=green:NoSchedule`
- Красный узел имеет Taint `color=red:NoSchedule`

### Шаг 2: Добавляем Tolerations в Pod'ы

**Синий Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: blue-pod
spec:
  tolerations:
  - key: color
    value: blue
    effect: NoSchedule
  containers:
  - name: app
    image: blue-app:latest
```

**Зеленый Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: green-pod
spec:
  tolerations:
  - key: color
    value: green
    effect: NoSchedule
  containers:
  - name: app
    image: green-app:latest
```

**Красный Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: red-pod
spec:
  tolerations:
  - key: color
    value: red
    effect: NoSchedule
  containers:
  - name: app
    image: red-app:latest
```

### Результат

```
┌─────────────────────────────────────────────────────────┐
│                    После размещения                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Синий узел          Зеленый узел       Другие узлы      │
│  ┌─────────┐         ┌─────────┐        ┌─────────┐    │
│  │ Taint:  │         │ Taint: │        │ No      │    │
│  │ blue    │         │ green  │        │ Taints  │    │
│  ├─────────┤         ├─────────┤        ├─────────┤    │
│  │ ✅ Синий │         │ ✅ Зеленый│     │ ❌ Красный│   │
│  │   Pod   │         │   Pod   │        │   Pod   │    │
│  └─────────┘         └─────────┘        └─────────┘    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

**Что получилось:**
- ✅ Синий Pod разместился на синем узле
- ✅ Зеленый Pod разместился на зеленом узле
- ❌ **Красный Pod разместился на другом узле** (не на красном!)

**Проблема:**
- ✅ Taints & Tolerations **гарантируют**, что другие Pod'ы НЕ попадут на наши узлы
- ❌ Taints & Tolerations **НЕ гарантируют**, что наши Pod'ы попадут на нужные узлы
- ❌ Красный Pod может разместиться на любом узле без Taints

**Почему это не работает?**

**Taints & Tolerations работают как "репеллент":**
- ✅ Отталкивают Pod'ы без Tolerations от узлов
- ❌ НЕ притягивают Pod'ы с Tolerations к узлам

**Красный Pod с Tolerations:**
- ✅ Может разместиться на красном узле (есть Tolerations)
- ✅ Может разместиться на любом другом узле без Taints (нет ограничений)

> ⚠️ **Вывод:** Taints & Tolerations — это механизм **отрицательного выбора** (negative selection), а не положительного.

---

</details>

<details>
<summary><b>❌Попытка 2: Только Node Affinity</b></summary>

---

## Решение через Node Affinity

### Шаг 1: Помечаем узлы метками

```bash
# Помечаем узлы соответствующими цветами через Labels
kubectl label node node1 color=blue
kubectl label node node2 color=green
kubectl label node node3 color=red
```

**Результат:**
- Синий узел имеет метку `color=blue`
- Зеленый узел имеет метку `color=green`
- Красный узел имеет метку `color=red`

### Шаг 2: Добавляем Node Affinity в Pod'ы

**Синий Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: blue-pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: color
            operator: In
            values:
            - blue
  containers:
  - name: app
    image: blue-app:latest
```

**Зеленый Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: green-pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: color
            operator: In
            values:
            - green
  containers:
  - name: app
    image: green-app:latest
```

**Красный Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: red-pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: color
            operator: In
            values:
            - red
  containers:
  - name: app
    image: red-app:latest
```

### Результат

```
┌─────────────────────────────────────────────────────────┐
│                    После размещения                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Синий узел          Зеленый узел       Красный узел    │
│  ┌─────────┐         ┌─────────┐        ┌─────────┐    │
│  │ Label: │         │ Label: │        │ Label: │    │
│  │ blue   │         │ green  │        │ red     │    │
│  ├─────────┤         ├─────────┤        ├─────────┤    │
│  │ ✅ Синий │         │ ✅ Зеленый│     │ ✅ Красный│   │
│  │   Pod   │         │   Pod   │        │   Pod   │    │
│  │ ❌ Другой │        │ ❌ Другой │      │         │    │
│  │   Pod   │         │   Pod   │        │         │    │
│  └─────────┘         └─────────┘        └─────────┘    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

**Что получилось:**
- ✅ Синий Pod разместился на синем узле
- ✅ Зеленый Pod разместился на зеленом узле
- ✅ Красный Pod разместился на красном узле
- ❌ **Другие Pod'ы также могут разместиться на наших узлах!**

**Проблема:**
- ✅ Node Affinity **гарантирует**, что наши Pod'ы попадут на нужные узлы
- ❌ Node Affinity **НЕ гарантирует**, что другие Pod'ы НЕ попадут на наши узлы
- ❌ Другие Pod'ы без Node Affinity могут разместиться на любых узлах, включая наши

**Почему это не работает?**

**Node Affinity работает как "магнит":**
- ✅ Притягивает Pod'ы к узлам с подходящими метками
- ❌ НЕ отталкивает другие Pod'ы от узлов

**Другие Pod'ы без Node Affinity:**
- ✅ Могут разместиться на любом узле (нет ограничений)
- ✅ Могут разместиться на наших узлах (нет Taints)

> ⚠️ **Вывод:** Node Affinity — это механизм **положительного выбора** (positive selection), который не защищает узлы от других Pod'ов.

---

</details>

<details>
<summary><b>✅Решение: Комбинация Taints & Tolerations + Node Affinity</b></summary>

---

## Полное решение

Комбинируем оба механизма для полного контроля:

1. **Taints & Tolerations** — защищают узлы от других Pod'ов
2. **Node Affinity** — направляют наши Pod'ы на нужные узлы

---

## Шаг 1: Применяем Taints на узлы (защита)

```bash
# Защищаем узлы от других Pod'ов через Taints
kubectl taint node node1 color=blue:NoSchedule
kubectl taint node node2 color=green:NoSchedule
kubectl taint node node3 color=red:NoSchedule
```

**Результат:**
- Другие Pod'ы НЕ смогут разместиться на наших узлах
- Только Pod'ы с соответствующими Tolerations смогут разместиться

---

## Шаг 2: Помечаем узлы метками (направление)

```bash
# Помечаем узлы для Node Affinity
kubectl label node node1 color=blue
kubectl label node node2 color=green
kubectl label node node3 color=red
```

**Результат:**
- Наши Pod'ы с Node Affinity будут направлены на нужные узлы

---

## Шаг 3: Создаем Pod'ы с Tolerations и Node Affinity

**Синий Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: blue-pod
spec:
  # Tolerations: разрешает размещение на синем узле
  tolerations:
  - key: color
    value: blue
    effect: NoSchedule
  
  # Node Affinity: направляет на синий узел
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: color
            operator: In
            values:
            - blue
  containers:
  - name: app
    image: blue-app:latest
```

**Зеленый Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: green-pod
spec:
  tolerations:
  - key: color
    value: green
    effect: NoSchedule
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: color
            operator: In
            values:
            - green
  containers:
  - name: app
    image: green-app:latest
```

**Красный Pod:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: red-pod
spec:
  tolerations:
  - key: color
    value: red
    effect: NoSchedule
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: color
            operator: In
            values:
            - red
  containers:
  - name: app
    image: red-app:latest
```

---

## Результат: Идеальное решение

```
┌─────────────────────────────────────────────────────────┐
│                    После размещения                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Синий узел          Зеленый узел       Красный узел    │
│  ┌─────────┐         ┌─────────┐        ┌─────────┐  │
│  │ Taint:  │         │ Taint: │        │ Taint:  │  │
│  │ blue    │         │ green  │        │ red     │  │
│  │ Label:  │         │ Label: │        │ Label:  │  │
│  │ blue    │         │ green  │        │ red     │  │
│  ├─────────┤         ├─────────┤        ├─────────┤  │
│  │ ✅ Синий │         │ ✅ Зеленый│     │ ✅ Красный│ │
│  │   Pod   │         │   Pod   │        │   Pod   │  │
│  │         │         │         │        │         │  │
│  └─────────┘         └─────────┘        └─────────┘  │
│                                                          │
│  Другие узлы                                             │
│  ┌─────────┐                                            │
│  │ Другие  │                                            │
│  │ Pod'ы   │                                            │
│  └─────────┘                                            │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

**Что получилось:**
- ✅ Синий Pod разместился на синем узле
- ✅ Зеленый Pod разместился на зеленом узле
- ✅ Красный Pod разместился на красном узле
- ✅ Другие Pod'ы НЕ могут разместиться на наших узлах
- ✅ Наши Pod'ы размещаются только на своих узлах

---

## Как это работает?

### Механизм защиты (Taints & Tolerations)

```
Другие Pod'ы (без Tolerations)
    ↓
Проверка Taints на узлах
    ↓
❌ Отклонены → Размещаются на других узлах
```

### Механизм направления (Node Affinity)

```
Наши Pod'ы (с Tolerations и Node Affinity)
    ↓
Проверка Taints → ✅ Проходят (есть Tolerations)
    ↓
Проверка Node Affinity → ✅ Направляются на нужные узлы
    ↓
✅ Размещаются на правильных узлах
```

---

</details>

<details>
<summary><b>📊Сравнительная таблица подходов</b></summary>

---

## Сравнение решений

| Критерий | Только Taints | Только Affinity | Комбинация |
|----------|---------------|-----------------|------------|
| **Наши Pod'ы на нужных узлах** | ❌ Нет гарантии | ✅ Да | ✅ Да |
| **Другие Pod'ы НЕ на наших узлах** | ✅ Да | ❌ Нет | ✅ Да |
| **Полная изоляция** | ❌ Нет | ❌ Нет | ✅ Да |
| **Сложность** | Простая | Средняя | Высокая |

---

## Когда использовать каждый подход?

### Только Taints & Tolerations

**Используйте, когда:**
- ✅ Нужно защитить узлы от других Pod'ов
- ✅ Не важно, на каком именно узле разместится Pod
- ✅ Простое решение

**Пример:** GPU-узлы для любых ML-приложений

### Только Node Affinity

**Используйте, когда:**
- ✅ Нужно направить Pod'ы на определенные узлы
- ✅ Не важно, размещаются ли другие Pod'ы на этих узлах
- ✅ Узлы не критичны для изоляции

**Пример:** Разделение по окружениям (dev/prod)

### Комбинация Taints + Node Affinity

**Используйте, когда:**
- ✅ Нужна полная изоляция узлов
- ✅ Нужно гарантировать размещение Pod'ов на определенных узлах
- ✅ Нужно защитить узлы от других Pod'ов
- ✅ Критичная инфраструктура

**Примеры:**
- Выделенные узлы для базы данных
- Изолированные узлы для критичных приложений
- Специализированные узлы (GPU, SSD) с полной изоляцией

---

</details>

---

## Резюме

✅ **Комбинация Taints & Tolerations + Node Affinity** — полное решение для выделения узлов

✅ **Taints & Tolerations:**
- Защищают узлы от других Pod'ов (отрицательный выбор)
- НЕ гарантируют размещение Pod'ов на нужных узлах

✅ **Node Affinity:**
- Направляют Pod'ы на нужные узлы (положительный выбор)
- НЕ защищают узлы от других Pod'ов

✅ **Комбинация:**
- ✅ Полная изоляция узлов
- ✅ Гарантированное размещение Pod'ов
- ✅ Защита от других Pod'ов
- ✅ Направление на нужные узлы

✅ **Когда использовать:**
- Критичная изоляция ресурсов
- Выделенные узлы для специализированных нагрузок
- Многоарендные кластеры
- Базы данных и критичные приложения

---