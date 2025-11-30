[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [🔄 K-09-Жизненный-цикл-приложений](../../README.md#-k-09-жизненный-цикл-приложений)

---

# 🔄K-09-1-Rolling-Updates-and-Rollbacks
>Rolling Updates и Rollbacks в Deployments: версионирование, стратегии развертывания (Recreate и RollingUpdate), обновление приложений и откат к предыдущим версиям

---

<details>
<summary><b>🔄Что такое Rollout?</b></summary>

---

## Концепция Rollout

Прежде чем мы рассмотрим, как обновлять наше приложение, давай попробуем разобраться в версионировании и откатах в Deployments.

Каждый раз при создании нового Deployment или обновлении образа в существующем, запускается Rollout.

**Rollout** — это процесс постепенного развертывания или обновления контейнеров приложений.

---

## Ревизии (Revisions)

Как я сказал, при создании Deployment запускается Rollout.

Этот Rollout создает ревизию развертывания, его отпечаток, снепшот.

Назовем его Revision 1.

В будущем, когда приложение будет обновлено:
- То есть когда версия контейнера будет меняться на новую
- Запустится новый Rollout
- Который создаст новую ревизию с именем **Revision 2**

---

## Зачем нужны ревизии?

Эта функция помогает нам:
- ✅ Отслеживать изменения, внесенные в deployment
- ✅ Позволяет при необходимости вернуться к предыдущей развернутой версии

---

## Просмотр состояния Rollout

Используй команду `kubectl rollout status`, за которой следует имя deployment, чтобы увидеть состояние выкатки:

```bash
kubectl rollout status deployment/<deployment-name>
```

Пример:

```bash
kubectl rollout status deployment/my-app
```

Вывод:

```
deployment "my-app" successfully rolled out
```

---

## Просмотр истории ревизий

Для просмотра списка ревизий и истории изменений выполни команду:

```bash
kubectl rollout history deployment/<deployment-name>
```

Пример:

```bash
kubectl rollout history deployment/my-app
```

Вывод:

```
REVISION  CHANGE-CAUSE
1         <none>
2         kubectl set image deployment/my-app nginx=nginx:1.21
```

---

</details>

<details>
<summary><b>📋Стратегии развертывания</b></summary>

---

## Два типа стратегий

В Kubernetes есть два типа стратегий развертывания.

Давай рассмотрим их на примере:
- У нас развернуто 4 реплики веб-приложения
- Нужно обновить их до новой версии

---

## Стратегия Recreate

Один из способов обновить их до нужной версии — уничтожить все инстансы, а затем создать экземпляры новой версии.

Это означает:
1. Сначала нужно уничтожить 4 запущенных экземпляра
2. Затем развернуть 4 новых экземпляра требуемой версии приложения

Проблема заключается в том, что:
- ❌ В течение периода между тем, как старые версии уже не работают, а новые еще не поднялись
- ❌ Приложение не запущено и недоступно для пользователей

Эта стратегия известна как Recreate strategy.

И, к счастью, это НЕ стратегия deployment по умолчанию.

---

## Стратегия RollingUpdate

Вторая стратегия заключается в том, что мы не уничтожаем все инстансы сразу.

Вместо этого:
1. Мы останавливаем экземпляр старой версии
2. И запускаем новый
3. И так один за другим

Таким образом:
- ✅ Приложение никогда не прекращает работу
- ✅ Обновление происходит плавно

---

## RollingUpdate по умолчанию

Имей в виду:
- Если ты не укажешь стратегию при создании deployment
- Kubernetes будет считать, что это **RollingUpdate**

Другими словами, RollingUpdate — это стратегия развертывания по умолчанию.

---

## Схема сравнения стратегий

```
┌─────────────────────────────────────────────────────────┐
│              Стратегия Recreate                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Старая версия (4 реплики)                              │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐                          │
│  │ v1 │ │ v1 │ │ v1 │ │ v1 │                          │
│  └────┘ └────┘ └────┘ └────┘                          │
│     │      │      │      │                             │
│     └──────┴──────┴──────┘                             │
│                    │                                    │
│                    ▼                                    │
│            ❌ Все остановлены                          │
│                    │                                    │
│                    ▼                                    │
│  Новая версия (4 реплики)                              │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐                          │
│  │ v2 │ │ v2 │ │ v2 │ │ v2 │                          │
│  └────┘ └────┘ └────┘ └────┘                          │
│                                                          │
│  ⚠️ Простой приложения!                                 │
│                                                          │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│              Стратегия RollingUpdate                   │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Старая версия → Новая версия (постепенно)              │
│                                                          │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐                          │
│  │ v1 │ │ v1 │ │ v1 │ │ v1 │                          │
│  └────┘ └────┘ └────┘ └────┘                          │
│     │      │      │      │                             │
│     ▼      │      │      │                             │
│  ┌────┐   │      │      │                             │
│  │ v2 │   │      │      │                             │
│  └────┘   │      │      │                             │
│     │      ▼      │      │                             │
│  ┌────┐ ┌────┐   │      │                             │
│  │ v2 │ │ v2 │   │      │                             │
│  └────┘ └────┘   │      │                             │
│     │      │      ▼      │                             │
│  ┌────┐ ┌────┐ ┌────┐   │                             │
│  │ v2 │ │ v2 │ │ v2 │   │                             │
│  └────┘ └────┘ └────┘   │                             │
│     │      │      │      ▼                             │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐                          │
│  │ v2 │ │ v2 │ │ v2 │ │ v2 │                          │
│  └────┘ └────┘ └────┘ └────┘                          │
│                                                          │
│  ✅ Приложение всегда доступно!                         │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Настройка стратегии в манифесте

**Пример с RollingUpdate (по умолчанию):**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  template:
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
```

**Пример с Recreate:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 4
  strategy:
    type: Recreate
  template:
    spec:
      containers:
      - name: nginx
        image: nginx:1.20
```

---

</details>

<details>
<summary><b>🔄Как обновлять Deployment?</b></summary>

---

## Что можно обновить?

Когда я говорю об обновлении, нужно понимать, что это могут быть разные вещи:

- ✅ Обновить версию Docker-образа нашего приложения
- ✅ Изменить версию приложения через образ
- ✅ Обновить метки Pod'ов
- ✅ Изменить количество реплик
- ✅ И другие параметры

---

## Способ 1: kubectl apply

Поскольку у нас есть файл определения deployment, нам легко внести изменения.

Процесс:

1. **Отредактируй файл манифеста:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 4
  template:
    spec:
      containers:
      - name: nginx
        image: nginx:1.21  # Обновлено с 1.20 до 1.21
```

2. После необходимых исправлений мы запускаем команду:

```bash
kubectl apply -f deployment.yaml
```

3. Запускается новый rollout и создается новая версия deployment.

---

## Способ 2: kubectl set image

Но есть ДРУГОЙ способ сделать то же самое.

Ты можешь использовать команду `kubectl set image` для обновления образа приложения:

```bash
kubectl set image deployment/<deployment-name> <container-name>=<new-image>
```

Пример:

```bash
kubectl set image deployment/my-app nginx=nginx:1.21
```

Это обновит образ контейнера `nginx` в deployment `my-app` до версии `1.21`.

---

## Важно: Дрифт конфигураций

Но помни:
- При использовании `kubectl set image`
- В манифесте останется старая версия образа
- И она будет отличаться от конфигурации в кластере

Это называется дрифт конфигураций (configuration drift).

Поэтому:
- Если ты практикуешь ручное конфигурирование
- Нужно быть аккуратным при использовании не обновленных файлов определения
- Всегда синхронизируй манифесты с реальным состоянием кластера

---

## Рекомендация

Лучшая практика:
- ✅ Используй `kubectl apply` с обновленным манифестом
- ✅ Храни манифесты в системе контроля версий
- ✅ Всегда обновляй манифесты при изменении конфигурации

---

</details>

<details>
<summary><b>🔍Просмотр деталей развертывания</b></summary>

---

## Команда kubectl describe

Разницу между стратегиями Recreate и RollingUpdate также можно увидеть при подробном рассмотрении deployment.

Запусти команду `kubectl describe deployment`, чтобы просмотреть подробную информацию о развертывании:

```bash
kubectl describe deployment <deployment-name>
```

---

## События при Recreate

Как видишь, при использовании стратегии Recreate события (events) показывают:

```
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  5s    deployment-controller  Scaled down replica set my-app-abc123 to 0
  Normal  ScalingReplicaSet  5s    deployment-controller  Scaled up replica set my-app-def456 to 3
```

Что происходит:
- Старый ReplicaSet сначала уменьшен до 0
- Новый ReplicaSet сразу увеличен до 3

---

## События при RollingUpdate

Однако, когда использовалась стратегия RollingUpdate:

```
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  10s   deployment-controller  Scaled down replica set my-app-abc123 to 2
  Normal  ScalingReplicaSet  10s   deployment-controller  Scaled up replica set my-app-def456 to 1
  Normal  ScalingReplicaSet  8s    deployment-controller  Scaled down replica set my-app-abc123 to 1
  Normal  ScalingReplicaSet  8s    deployment-controller  Scaled up replica set my-app-def456 to 2
  Normal  ScalingReplicaSet  5s    deployment-controller  Scaled down replica set my-app-abc123 to 0
  Normal  ScalingReplicaSet  5s    deployment-controller  Scaled up replica set my-app-def456 to 3
```

Что происходит:
- Старый ReplicaSet уменьшался по одному
- В соответствии с этим также увеличивалось количество реплик нового ReplicaSet

---

</details>

<details>
<summary><b>⚙️Как работает Deployment под капотом?</b></summary>

---

## Создание Deployment

Заглянем deployment под "капот".

Когда создается новый deployment, скажем, для развертывания 5 реплик:

1. Он сначала автоматически создает **ReplicaSet**
2. Который, в свою очередь, создает количество Pod'ов, необходимое для соответствия количеству реплик

```
┌─────────────────────────────────────────────────────────┐
│              Создание Deployment                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Deployment (5 реплик)                                  │
│           │                                              │
│           ▼                                              │
│  ReplicaSet (автоматически создан)                      │
│           │                                              │
│           ▼                                              │
│  Pod Pod Pod Pod Pod (5 Pod'ов)                        │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Обновление Deployment

Когда ты обновляешь свое приложение, как мы видели на предыдущем слайде:

1. Объект deployment создает **НОВЫЙ ReplicaSet**
2. И начинает развертывание контейнеров в нем
3. В то же время удаление Pod'ов в старом ReplicaSet идет в соответствии со стратегией RollingUpdate

```
┌─────────────────────────────────────────────────────────┐
│              Обновление Deployment                       │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  Deployment                                              │
│           │                                              │
│           ├─ Старый ReplicaSet (v1)                     │
│           │  └─ Pod Pod Pod (уменьшается)               │
│           │                                              │
│           └─ Новый ReplicaSet (v2)                      │
│              └─ Pod Pod Pod (увеличивается)             │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Просмотр ReplicaSet'ов

Это можно увидеть с помощью команды:

```bash
kubectl get replicasets
```

Вывод:

```
NAME                DESIRED   CURRENT   READY   AGE
my-app-abc123       0         0         0       10m    # Старый ReplicaSet
my-app-def456       5         5         5       2m     # Новый ReplicaSet
```

Здесь мы видим:
- Старый набор реплик с 0 Pod'ов
- Новый набор реплик с 5 Pod'ов

---

## Связь между объектами

Важно понимать:
- Deployment управляет ReplicaSet'ами
- ReplicaSet управляет Pod'ами
- При обновлении создается новый ReplicaSet
- Старый ReplicaSet сохраняется для возможности отката

---

</details>

<details>
<summary><b>⏪Откат изменений (Rollback)</b></summary>

---

## Когда нужен откат?

Допустим, мы обновили свое приложение, и вдруг поняли, что что-то пошло не так.

Что-то неправильно с новой версией сборки, которую мы использовали для обновления.

Итак, нам надо откатить обновление.

---

## Команда kubectl rollout undo

Deployments Kubernetes позволяют вернуться к предыдущей версии.

Чтобы отменить изменение, выполни команду:

```bash
kubectl rollout undo deployment/<deployment-name>
```

Пример:

```bash
kubectl rollout undo deployment/my-app
```

---

## Что происходит при откате?

После этого:
1. Deployment уничтожит Pod'ы в новом ReplicaSet
2. И восстановит старые Pod'ы в старом ReplicaSet

Как видишь, наше приложение вернулось к своему старому виду.

---

## Сравнение до и после отката

Сравним вывод команды `kubectl get replicasets` до и после отката.

Перед откатом:

```bash
kubectl get replicasets
```

```
NAME                DESIRED   CURRENT   READY   AGE
my-app-abc123       0         0         0       10m    # Старый (v1)
my-app-def456       5         5         5       2m     # Новый (v2)
```

После завершения отката:

```bash
kubectl get replicasets
```

```
NAME                DESIRED   CURRENT   READY   AGE
my-app-abc123       5         5         5       10m    # Старый (v1) - восстановлен
my-app-def456       0         0         0       2m      # Новый (v2) - уменьшен до 0
```

Все стало наоборот.

---

## Откат к конкретной ревизии

Чтобы откатиться к конкретной ревизии:

```bash
kubectl rollout undo deployment/<deployment-name> --to-revision=<revision-number>
```

Пример:

```bash
kubectl rollout undo deployment/my-app --to-revision=1
```

Это откатит deployment к Revision 1.

---

## Просмотр деталей ревизии

Чтобы увидеть детали конкретной ревизии:

```bash
kubectl rollout history deployment/<deployment-name> --revision=<revision-number>
```

Пример:

```bash
kubectl rollout history deployment/my-app --revision=2
```

---

</details>

<details>
<summary><b>🚀Быстрое создание Deployment</b></summary>

---

## Команда kubectl create deployment

Как и в случае для Pod, deployment можно создать быстрой командой:

```bash
kubectl create deployment <deployment-name> --image=<image-name>
```

С указанием образа.

Очень похоже на команду `kubectl run` для создания Pod.

---

## Пример

Пример:

```bash
kubectl create deployment my-app --image=nginx:1.20
```

Это один из способов создания развертываний:
- Указав только имя образа
- Не используя файл определения

В свою очередь:
- ReplicaSet и Pod'ы создаются автоматически

---

## Рекомендация

Тем не менее, рекомендуется использовать манифест, поскольку:
- ✅ Появляется возможность сохранить файл в системе контроля версий
- ✅ При необходимости изменить его позже
- ✅ Это является хорошей практикой в свете принципа "Инфраструктура-как-код" (Infrastructure as Code)

---

</details>

<details>
<summary><b>📝Резюме команд</b></summary>

---

## Команды для работы с Deployments

Давай быстро пробежимся по командам, для резюмации.

---

### Создание

Используй команду `kubectl create` для создания deployment:

```bash
kubectl create deployment <name> --image=<image>
```

Или через манифест:

```bash
kubectl create -f deployment.yaml
```

---

### Просмотр

Команду `get deployments` для получения списка развертываний:

```bash
kubectl get deployments
```

Или сокращенно:

```bash
kubectl get deploy
```

---

### Обновление

Команды `apply` и `set image` для обновления deployments:

```bash
kubectl apply -f deployment.yaml
```

```bash
kubectl set image deployment/<name> <container>=<new-image>
```

---

### Масштабирование

Команду `scale` для масштабирования:

```bash
kubectl scale deployment/<name> --replicas=<number>
```

Пример:

```bash
kubectl scale deployment/my-app --replicas=5
```

---

### Rollout

Команду `rollout status`, чтобы увидеть состояние выкатки:

```bash
kubectl rollout status deployment/<name>
```

Команду `rollout history` для истории ревизий:

```bash
kubectl rollout history deployment/<name>
```

Команду `rollout undo` для отката на другую ревизию:

```bash
kubectl rollout undo deployment/<name>
```

Или к конкретной ревизии:

```bash
kubectl rollout undo deployment/<name> --to-revision=<number>
```

---

</details>

---

## Резюме

✅ **Rollout** — процесс постепенного развертывания или обновления контейнеров приложений

✅ **Ревизии (Revisions):**
- Каждое обновление создает новую ревизию
- Помогают отслеживать изменения
- Позволяют вернуться к предыдущей версии

✅ **Стратегии развертывания:**
- **Recreate** — уничтожает все старые Pod'ы, затем создает новые (простой приложения)
- **RollingUpdate** — обновляет постепенно, по одному Pod'у (по умолчанию, приложение всегда доступно)

✅ **Обновление Deployment:**
- `kubectl apply -f deployment.yaml` — через манифест (рекомендуется)
- `kubectl set image` — прямое обновление образа (может вызвать дрифт конфигураций)

✅ **Как работает под капотом:**
- Deployment создает ReplicaSet'ы
- При обновлении создается новый ReplicaSet
- Старый ReplicaSet сохраняется для отката

✅ **Откат изменений:**
- `kubectl rollout undo` — откат к предыдущей версии
- `kubectl rollout undo --to-revision=<number>` — откат к конкретной ревизии
- `kubectl rollout history` — просмотр истории ревизий

✅ **Команды:**
- `kubectl create deployment` — создание
- `kubectl get deployments` — просмотр
- `kubectl apply` / `kubectl set image` — обновление
- `kubectl scale` — масштабирование
- `kubectl rollout status` — состояние выкатки
- `kubectl rollout history` — история ревизий
- `kubectl rollout undo` — откат

> 💡 **Совет:** Всегда используй манифесты для управления Deployments. Это позволяет отслеживать изменения, хранить конфигурацию в системе контроля версий и избегать дрифта конфигураций. RollingUpdate — стратегия по умолчанию, которая обеспечивает доступность приложения во время обновления.

---

