[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [💾 K-12-Хранение](../../README.md#-k-12-хранение)

---

# 💾K-12-7-Persistent-Volume-Claims
>Persistent Volume Claims (PVC) в Kubernetes: запросы на хранилище, привязка к PV, использование в POD, reclaim policy, метки и селекторы

**📍 Текущая тема**

---

<details>
<summary><b>📚Введение: Persistent Volume Claims</b></summary>

---

## Связь с предыдущей темой

В теме [K-12-6-Persistent-Volumes](K-12-6-Persistent-Volumes.md) мы рассмотрели создание Persistent Volumes (PV) администратором кластера.

Теперь изучим Persistent Volume Claims (PVC) — механизм, с помощью которого пользователи запрашивают хранилище из пула PV.

---

## Разделение ответственности

Persistent Volumes и Persistent Volume Claims — это два отдельных объекта Kubernetes, которые работают в паре:

- **Persistent Volume (PV)** — создается администратором кластера, представляет физическое или логическое хранилище
- **Persistent Volume Claim (PVC)** — создается пользователем, представляет запрос на использование хранилища

### Схема разделения ответственности

```
┌─────────────────────────────────────────────────────────┐
│  Администратор кластера                                 │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Создает Persistent Volumes (PV)                 │   │
│  │  - Настраивает доступное хранилище                │   │
│  │  - Определяет capacity, accessModes               │   │
│  │  - Указывает тип хранилища                        │   │
│  │  - Создает пул доступных томов                    │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                 │
│                        ▼                                 │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Пользователь приложения                         │   │
│  │  ┌─────────────────────────────────────────────┐ │   │
│  │  │  Создает Persistent Volume Claim (PVC)       │ │   │
│  │  │  - Запрашивает хранилище                     │ │   │
│  │  │  - Указывает требуемый объем                 │ │   │
│  │  │  - Указывает режим доступа                   │ │   │
│  │  │  - Использует PVC в POD                      │ │   │
│  │  └─────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## Процесс привязки (Binding)

После создания PVC Kubernetes автоматически ищет подходящий PV и привязывает его к заявке.

### Критерии привязки

Kubernetes выбирает PV на основе следующих критериев:

- **Емкость (capacity)** — PV должен иметь достаточную или большую емкость
- **Режим доступа (accessModes)** — должен соответствовать запросу PVC
- **Режим тома (volumeMode)** — Filesystem или Block
- **Класс хранения (storageClass)** — должен соответствовать (если указан)
- **Метки (labels)** — для явной привязки через селекторы

### Схема процесса привязки

```
┌─────────────────────────────────────────────────────────┐
│  PVC создан                                              │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Запрос: 500Mi, ReadWriteOnce                    │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                 │
│            Kubernetes ищет подходящий PV                │
│                        │                                 │
│                        ▼                                 │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Доступные PV:                                   │   │
│  │  - PV-1: 1Gi, ReadWriteOnce ✓                   │   │
│  │  - PV-2: 2Gi, ReadOnlyMany ✗                    │   │
│  │  - PV-3: 500Mi, ReadWriteOnce ✓                 │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                 │
│            Выбор наиболее подходящего PV                │
│                        │                                 │
│                        ▼                                 │
│  ┌──────────────────────────────────────────────────┐   │
│  │  PVC ←→ PV (Bound)                               │   │
│  │  Статус: Bound                                   │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

</details>

<details>
<summary><b>🔗Взаимно однозначная связь</b></summary>

---

## Связь один-к-одному

Между PVC и PV существует взаимно однозначная связь (one-to-one relationship).

### Особенности связи

- Один PVC может быть привязан только к одному PV
- Один PV может быть привязан только к одному PVC
- Если PV имеет большую емкость, чем запрошено в PVC, оставшаяся емкость не может быть использована другими PVC

### Схема взаимно однозначной связи

```
┌─────────────────────────────────────────────────────────┐
│  Persistent Volume (PV)                                 │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Capacity: 10Gi                                   │   │
│  │  AccessMode: ReadWriteOnce                        │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                 │
│            ┌───────────┴───────────┐                     │
│            │                       │                     │
│            ▼                       ▼                     │
│  ┌─────────────────┐     ┌─────────────────┐            │
│  │  PVC-1: 5Gi     │     │  PVC-2: 3Gi     │            │
│  │  Status: Bound  │     │  Status: Bound  │            │
│  └─────────────────┘     └─────────────────┘            │
│                                                           │
│  ❌ Невозможно: один PV → несколько PVC                  │
│  ❌ Невозможно: один PVC → несколько PV                  │
│  ✅ Возможно: один PV → один PVC                          │
└─────────────────────────────────────────────────────────┘
```

---

## Состояния PVC

PVC может находиться в различных состояниях:

- **Pending** — заявка создана, но подходящий PV не найден
- **Bound** — PVC успешно привязан к PV
- **Lost** — связанный PV был удален

### Схема состояний PVC

```
┌─────────────────────────────────────────────────────────┐
│  Pending (ожидание)                                      │
│  ┌──────────────────────────────────────────────────┐   │
│  │  PVC создан, но подходящий PV не найден          │   │
│  │  - Нет доступных PV с нужными параметрами        │   │
│  │  - Ожидание освобождения или создания PV         │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                 │
│            Подходящий PV найден                          │
│                        │                                 │
│                        ▼                                 │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Bound (привязан)                                │   │
│  │  ┌─────────────────────────────────────────────┐ │   │
│  │  │  PVC успешно привязан к PV                   │ │   │
│  │  │  Готов к использованию в POD                 │ │   │
│  │  └─────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

</details>

<details>
<summary><b>📝Создание Persistent Volume Claim</b></summary>

---

## Структура определения PVC

Определение PVC состоит из следующих основных секций:

- **apiVersion** — версия API (v1)
- **kind** — тип ресурса (PersistentVolumeClaim)
- **metadata** — метаданные (имя, namespace, метки)
- **spec** — спецификация (accessModes, resources, storageClass)

### Пример базового определения PVC

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: claim-volume1
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

---

## Параметры спецификации

### accessModes

Режимы доступа определяют, как том может быть смонтирован:

- **ReadWriteOnce (RWO)** — чтение и запись для одного узла
- **ReadOnlyMany (ROX)** — только чтение для многих узлов
- **ReadWriteMany (RWX)** — чтение и запись для многих узлов

### resources.requests.storage

Запрашиваемый объем хранилища. Может быть указан в различных единицах:

- `Ki` — кибибайты (1024 байта)
- `Mi` — мебибайты (1024² байта)
- `Gi` — гибибайты (1024³ байта)
- `Ti` — тебибайты (1024⁴ байта)

### storageClass

Класс хранения определяет тип провайдера и параметры хранилища. Если не указан, используется класс по умолчанию.

---

## Создание PVC

### Команда создания

```bash
# Создание PVC из файла
kubectl create -f pvc-definition.yaml

# Или прямое создание
kubectl create -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: claim-volume1
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
EOF
```

### Просмотр созданных PVC

```bash
# Список всех PVC
kubectl get pvc

# Сокращенная форма
kubectl get pvc

# Детальная информация
kubectl describe pvc claim-volume1

# YAML представление
kubectl get pvc claim-volume1 -o yaml
```

### Пример вывода

```bash
$ kubectl get pvc
NAME            STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS   AGE
claim-volume1   Bound    pv-volume1   1Gi        RWO            manual         5m
```

---

## Процесс привязки на примере

Рассмотрим пример привязки PVC к существующему PV:

### Исходные условия

- **PV**: `pv-volume1`, capacity: 1Gi, accessMode: ReadWriteOnce
- **PVC**: `claim-volume1`, запрос: 500Mi, accessMode: ReadWriteOnce

### Схема привязки

```
┌─────────────────────────────────────────────────────────┐
│  Шаг 1: PVC создан                                       │
│  ┌──────────────────────────────────────────────────┐   │
│  │  PVC: claim-volume1                              │   │
│  │  Запрос: 500Mi, ReadWriteOnce                    │   │
│  │  Статус: Pending                                 │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                 │
│            Kubernetes ищет подходящий PV                │
│                        │                                 │
│                        ▼                                 │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Шаг 2: Проверка доступных PV                    │   │
│  │  ┌─────────────────────────────────────────────┐ │   │
│  │  │  PV: pv-volume1                             │ │   │
│  │  │  Capacity: 1Gi (≥ 500Mi) ✓                  │ │   │
│  │  │  AccessMode: ReadWriteOnce ✓                │ │   │
│  │  │  Статус: Available                          │ │   │
│  │  └─────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                 │
│            Привязка выполнена                           │
│                        │                                 │
│                        ▼                                 │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Шаг 3: PVC привязан                             │   │
│  │  ┌─────────────────────────────────────────────┐ │   │
│  │  │  PVC: claim-volume1                        │ │   │
│  │  │  Статус: Bound                              │ │   │
│  │  │  Привязан к: pv-volume1                     │ │   │
│  │  └─────────────────────────────────────────────┘ │   │
│  │  ┌─────────────────────────────────────────────┐ │   │
│  │  │  PV: pv-volume1                            │ │   │
│  │  │  Статус: Bound                              │ │   │
│  │  │  Привязан к: claim-volume1                  │ │   │
│  │  └─────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

</details>

<details>
<summary><b>🏷️Метки и селекторы для явной привязки</b></summary>

---

## Явная привязка PVC к PV

Если в кластере доступно несколько подходящих PV, можно использовать метки (labels) и селекторы (selectors) для явной привязки PVC к конкретному PV.

### Создание PV с метками

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-volume1
  labels:
    type: fast-ssd
    environment: production
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /data/pv1
```

### Создание PVC с селектором

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: claim-volume1
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
  selector:
    matchLabels:
      type: fast-ssd
      environment: production
```

---

## Селекторы в PVC

PVC поддерживает различные типы селекторов:

### matchLabels

Точное совпадение меток:

```yaml
selector:
  matchLabels:
    type: fast-ssd
    environment: production
```

### matchExpressions

Выражения для более сложных условий:

```yaml
selector:
  matchExpressions:
    - key: type
      operator: In
      values:
        - fast-ssd
        - standard-ssd
    - key: environment
      operator: NotIn
      values:
        - development
```

### Операторы

- **In** — значение метки в списке
- **NotIn** — значение метки не в списке
- **Exists** — метка существует
- **DoesNotExist** — метка не существует

---

## Схема привязки с селекторами

```
┌─────────────────────────────────────────────────────────┐
│  Доступные PV                                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │  PV-1: type=fast-ssd, env=production             │   │
│  │  PV-2: type=standard-ssd, env=production        │   │
│  │  PV-3: type=fast-ssd, env=development            │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                 │
│            PVC с селектором                             │
│            selector:                                    │
│              type: fast-ssd                             │
│              environment: production                     │
│                        │                                 │
│                        ▼                                 │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Подходящие PV:                                   │   │
│  │  ✓ PV-1: совпадает                               │   │
│  │  ✗ PV-2: type не совпадает                       │   │
│  │  ✗ PV-3: environment не совпадает                │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                 │
│            Привязка к PV-1                              │
│                        │                                 │
│                        ▼                                 │
│  ┌──────────────────────────────────────────────────┐   │
│  │  PVC ←→ PV-1 (Bound)                             │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

</details>

<details>
<summary><b>🗑️Reclaim Policy</b></summary>

---

## Политика освобождения

Reclaim Policy определяет поведение PV после удаления связанного PVC.

### Типы политик

- **Retain** — том сохраняется, данные остаются, требуется ручная очистка
- **Delete** — том автоматически удаляется вместе с данными
- **Recycle** — том очищается для повторного использования (deprecated)

---

## Retain Policy

При политике `Retain` PV остается в кластере после удаления PVC, но становится недоступным для других PVC до ручной очистки администратором.

### Схема жизненного цикла с Retain

```
┌─────────────────────────────────────────────────────────┐
│  PV: Bound                                               │
│  ┌──────────────────────────────────────────────────┐   │
│  │  PVC ←→ PV (Bound)                               │   │
│  │  ReclaimPolicy: Retain                           │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                 │
│            PVC удален                                   │
│                        │                                 │
│                        ▼                                 │
│  ┌──────────────────────────────────────────────────┐   │
│  │  PV: Released                                     │   │
│  │  ┌─────────────────────────────────────────────┐ │   │
│  │  │  PVC удален                                  │ │   │
│  │  │  Данные сохранены                            │ │   │
│  │  │  PV недоступен для новых PVC                 │ │   │
│  │  │  Требуется ручная очистка администратором    │ │   │
│  │  └─────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                 │
│            Администратор очищает PV                      │
│                        │                                 │
│                        ▼                                 │
│  ┌──────────────────────────────────────────────────┐   │
│  │  PV: Available                                    │   │
│  │  Готов к повторному использованию                 │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### Пример с Retain

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-volume1
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /data/pv1
```

---

## Delete Policy

При политике `Delete` PV автоматически удаляется вместе с данными после удаления PVC.

### Схема жизненного цикла с Delete

```
┌─────────────────────────────────────────────────────────┐
│  PV: Bound                                               │
│  ┌──────────────────────────────────────────────────┐   │
│  │  PVC ←→ PV (Bound)                               │   │
│  │  ReclaimPolicy: Delete                           │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                 │
│            PVC удален                                   │
│                        │                                 │
│                        ▼                                 │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Автоматическое удаление                          │   │
│  │  ┌─────────────────────────────────────────────┐ │   │
│  │  │  PV удален из кластера                       │ │   │
│  │  │  Данные удалены с устройства хранения        │ │   │
│  │  │  Место освобождено                           │ │   │
│  │  └─────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### Пример с Delete

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-aws-ebs
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  awsElasticBlockStore:
    volumeID: vol-12345678
    fsType: ext4
```

---

## Recycle Policy (Deprecated)

Политика `Recycle` помечена как устаревшая (deprecated) начиная с Kubernetes 1.14.

Вместо нее рекомендуется использовать Dynamic Provisioning с StorageClasses.

---

## Сравнение политик

| Политика | Поведение после удаления PVC | Использование данных | Автоматизация |
|----------|------------------------------|---------------------|---------------|
| **Retain** | PV остается, данные сохраняются | Сохраняются | Требуется ручная очистка |
| **Delete** | PV и данные удаляются | Удаляются | Полностью автоматически |
| **Recycle** | Данные очищаются, PV доступен | Очищаются | Автоматически (deprecated) |

---

</details>

<details>
<summary><b>📦Использование PVC в POD</b></summary>

---

## Монтирование PVC в POD

После создания и привязки PVC его можно использовать в определении POD, указав имя PVC в секции `volumes`.

### Определение POD с PVC

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-pvc
spec:
  containers:
    - name: app-container
      image: nginx
      volumeMounts:
        - name: data-volume
          mountPath: /opt
  volumes:
    - name: data-volume
      persistentVolumeClaim:
        claimName: claim-volume1
```

---

## Схема использования PVC в POD

```
┌─────────────────────────────────────────────────────────┐
│  POD Definition                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  volumes:                                        │   │
│  │    - name: data-volume                           │   │
│  │      persistentVolumeClaim:                      │   │
│  │        claimName: claim-volume1                  │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                 │
│            Kubernetes разрешает PVC                     │
│                        │                                 │
│                        ▼                                 │
│  ┌──────────────────────────────────────────────────┐   │
│  │  PVC: claim-volume1                               │   │
│  │  Статус: Bound                                    │   │
│  │  Привязан к: pv-volume1                           │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                 │
│            Монтирование PV в POD                         │
│                        │                                 │
│                        ▼                                 │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Container: app-container                         │   │
│  │  ┌─────────────────────────────────────────────┐ │   │
│  │  │  /opt → /data/pv1 (из PV)                   │ │   │
│  │  │  Данные сохраняются на устройстве хранения   │ │   │
│  │  └─────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## Полный пример

### 1. Создание PV

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-volume1
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /data/pv1
```

### 2. Создание PVC

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: claim-volume1
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

### 3. Создание POD с PVC

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-server
spec:
  containers:
    - name: nginx
      image: nginx:latest
      volumeMounts:
        - name: web-storage
          mountPath: /usr/share/nginx/html
  volumes:
    - name: web-storage
      persistentVolumeClaim:
        claimName: claim-volume1
```

### 4. Команды для создания

```bash
# Создание PV
kubectl create -f pv.yaml

# Создание PVC
kubectl create -f pvc.yaml

# Проверка привязки
kubectl get pvc

# Создание POD
kubectl create -f pod.yaml

# Проверка монтирования
kubectl describe pod web-server
```

---

</details>

<details>
<summary><b>🚀Использование PVC в Deployments и ReplicaSets</b></summary>

---

## PVC в ReplicaSet

PVC можно использовать в ReplicaSet, добавив определение volumes в секцию `template.spec`.

### Пример ReplicaSet с PVC

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: web-rs
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          volumeMounts:
            - name: web-storage
              mountPath: /usr/share/nginx/html
      volumes:
        - name: web-storage
          persistentVolumeClaim:
            claimName: claim-volume1
```

---

## PVC в Deployment

Аналогично, PVC используется в Deployment через секцию `template.spec`.

### Пример Deployment с PVC

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: nginx
          image: nginx:latest
          volumeMounts:
            - name: web-storage
              mountPath: /usr/share/nginx/html
      volumes:
        - name: web-storage
          persistentVolumeClaim:
            claimName: claim-volume1
```

---

## Важные замечания

### ReadWriteOnce ограничение

Если PVC использует `ReadWriteOnce` (RWO), только один POD может монтировать том одновременно.

При попытке создать несколько POD с одним RWO PVC, дополнительные POD будут оставаться в состоянии `Pending`.

### Схема ограничения RWO

```
┌─────────────────────────────────────────────────────────┐
│  PVC: claim-volume1                                      │
│  AccessMode: ReadWriteOnce                               │
│  ┌──────────────────────────────────────────────────┐   │
│  │  POD-1: Running                                  │   │
│  │  Том смонтирован ✓                               │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                 │
│            Попытка монтирования POD-2                    │
│                        │                                 │
│                        ▼                                 │
│  ┌──────────────────────────────────────────────────┐   │
│  │  POD-2: Pending                                  │   │
│  │  Ошибка: том уже смонтирован другим POD         │   │
│  │  ReadWriteOnce позволяет только одно монтирование│   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### Решения для множественных POD

Для использования одного тома несколькими POD необходимо:

- Использовать `ReadWriteMany` (RWX) accessMode
- Использовать сетевые хранилища (NFS, CephFS, GlusterFS)
- Использовать StatefulSet с отдельными PVC для каждого POD

---

## Схема использования в Deployment

```
┌─────────────────────────────────────────────────────────┐
│  Deployment: web-deployment                              │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Replicas: 3                                     │   │
│  │  Template:                                       │   │
│  │    volumes:                                      │   │
│  │      - persistentVolumeClaim:                   │   │
│  │          claimName: claim-volume1                │   │
│  └──────────────────────────────────────────────────┘   │
│                        │                                 │
│            Создание POD реплик                           │
│                        │                                 │
│                        ▼                                 │
│  ┌──────────────────────────────────────────────────┐   │
│  │  POD-1 ←→ PVC ←→ PV                               │   │
│  │  POD-2 ←→ PVC ←→ PV (если RWX)                   │   │
│  │  POD-3 ←→ PVC ←→ PV (если RWX)                   │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

</details>

<details>
<summary><b>⚠️Важные замечания</b></summary>

---

## Ограничения емкости

PVC может быть привязан к PV с большей емкостью, чем запрошено, но оставшаяся емкость не может быть использована другими PVC.

### Пример

- **PV**: 10Gi
- **PVC-1**: запрос 3Gi → привязан к PV
- **Оставшаяся емкость**: 7Gi недоступна для других PVC

Это связано с взаимно однозначной связью между PVC и PV.

---

## Состояние Pending

Если подходящий PV не найден, PVC остается в состоянии `Pending` до тех пор, пока:

- Не будет создан новый подходящий PV
- Не освободится существующий PV (после удаления связанного PVC)

### Проверка состояния Pending

```bash
# Просмотр PVC в состоянии Pending
kubectl get pvc

# Детальная информация о причинах
kubectl describe pvc claim-volume1
```

### Типичные причины Pending

- Нет доступных PV с требуемым accessMode
- Нет доступных PV с достаточной емкостью
- Все подходящие PV уже привязаны к другим PVC
- Селекторы не соответствуют ни одному PV

---

## Удаление PVC

### Команда удаления

```bash
# Удаление PVC
kubectl delete pvc claim-volume1

# Или из файла
kubectl delete -f pvc-definition.yaml
```

### Поведение PV после удаления PVC

Поведение зависит от `persistentVolumeReclaimPolicy`:

- **Retain**: PV переходит в состояние `Released`, данные сохраняются
- **Delete**: PV удаляется автоматически вместе с данными
- **Recycle**: PV очищается и становится доступным (deprecated)

---

## Проверка привязки

### Команды для проверки

```bash
# Список всех PVC
kubectl get pvc

# Список всех PV
kubectl get pv

# Детальная информация о PVC
kubectl describe pvc claim-volume1

# Детальная информация о PV
kubectl describe pv pv-volume1

# Проверка событий
kubectl get events --sort-by=.metadata.creationTimestamp
```

---

</details>

---

## Резюме

### Разделение ответственности

- **Persistent Volume (PV)** — создается администратором, представляет хранилище
- **Persistent Volume Claim (PVC)** — создается пользователем, запрашивает хранилище

### Процесс привязки

- Kubernetes автоматически привязывает PVC к подходящему PV
- Критерии: capacity, accessModes, volumeMode, storageClass, labels
- Взаимно однозначная связь: один PVC ↔ один PV

### Состояния PVC

- **Pending** — ожидание подходящего PV
- **Bound** — успешно привязан к PV
- **Lost** — связанный PV удален

### Reclaim Policy

- **Retain** — PV сохраняется, требуется ручная очистка
- **Delete** — PV удаляется автоматически
- **Recycle** — очистка и повторное использование (deprecated)

### Использование в POD

- Указание PVC в секции `volumes` через `persistentVolumeClaim.claimName`
- Монтирование в контейнер через `volumeMounts`
- Ограничения `ReadWriteOnce` для множественных POD

### Использование в Deployments/ReplicaSets

- Добавление PVC в секцию `template.spec.volumes`
- Учет ограничений accessModes при масштабировании

---

## Связанные темы

- **[K-12-1-Enter-Container-Storage](K-12-1-Enter-Container-Storage.md)** — введение в концепции хранения в Docker
- **[K-12-2-Storage-in-Docker](K-12-2-Storage-in-Docker.md)** — volumes в Docker
- **[K-12-3-Volume-Driver-Plugins-in-Docker](K-12-3-Volume-Driver-Plugins-in-Docker.md)** — volume driver plugins
- **[K-12-4-CSI](K-12-4-CSI.md)** — Container Storage Interface
- **[K-12-5-Volumes](K-12-5-Volumes.md)** — volumes в Kubernetes, типы volumes и их использование
- **[K-12-6-Persistent-Volumes](K-12-6-Persistent-Volumes.md)** — Persistent Volumes, централизованное управление хранилищем
- **[K-12-7-Persistent-Volume-Claims](K-12-7-Persistent-Volume-Claims.md)** — Persistent Volume Claims, запросы на хранилище **← Текущая тема**

---

## Что дальше?

В следующей теме мы рассмотрим StorageClasses — механизм динамического выделения хранилища, который автоматизирует создание PV при создании PVC.

---
