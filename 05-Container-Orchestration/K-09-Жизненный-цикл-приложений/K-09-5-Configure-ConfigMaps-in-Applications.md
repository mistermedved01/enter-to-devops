[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [🔄 K-09-Жизненный-цикл-приложений](../../README.md#-k-09-жизненный-цикл-приложений)

---

# 📋K-09-5-Configure-ConfigMaps-in-Applications
>ConfigMaps в Kubernetes: создание (императивный и декларативный методы), использование envFrom, инжекция в Pods, Kustomize

---

<details>
<summary><b>🎯Введение: зачем нужны ConfigMaps</b></summary>

---

## О чем эта лекция

Привет и добро пожаловать на лекцию. В этой лекции мы обсудим, как работать с данными конфигураций в Kubernetes.

В предыдущей лекции мы увидели, как определять переменные среды в файле определения POD.

Когда у тебя много разных манифестов, становится сложно управлять переменными сред, хранящимися в этих файлах определений.

Мы можем извлечь эту информацию из файла и централизованно управлять ею с помощью карт конфигураций — configuration maps.

Или короче — ConfigMaps.

---

## Что такое ConfigMap?

Они используются в Kubernetes для передачи данных конфигураций в виде пар ключ-значение.

Когда POD создан, мы инжектируем в него ConfigMap.

Таким образом, пары ключ-значение станут доступны в качестве переменных среды для приложений, размещенных внутри контейнера в POD.

---

## Проблема без ConfigMaps

**Без ConfigMaps:**

```yaml
# pod1.yaml
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: app
    env:
    - name: DATABASE_URL
      value: "postgresql://localhost:5432/mydb"
    - name: API_KEY
      value: "abc123"

# pod2.yaml
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: app
    env:
    - name: DATABASE_URL
      value: "postgresql://localhost:5432/mydb"  # Дублирование!
    - name: API_KEY
      value: "abc123"  # Дублирование!
```

**Проблемы:**
- ❌ Дублирование конфигурации
- ❌ Сложно обновлять
- ❌ Риск ошибок при копировании

---

## Решение с ConfigMaps

**С ConfigMaps:**

```yaml
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DATABASE_URL: "postgresql://localhost:5432/mydb"
  API_KEY: "abc123"

# pod1.yaml и pod2.yaml
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: app
    envFrom:
    - configMapRef:
        name: app-config
```

**Преимущества:**
- ✅ Централизованное управление
- ✅ Легко обновлять
- ✅ Переиспользование

---

</details>

<details>
<summary><b>🔧Два этапа настройки ConfigMaps</b></summary>

---

## Этапы настройки

Настройка ConfigMaps состоит из двух этапов:

1. ✅ **Сначала создай ConfigMaps**
2. ✅ **Затем введи их в POD**

---

## Шаг 1: Создание ConfigMap

Создай ConfigMap с данными конфигурации:

```bash
kubectl create configmap app-config --from-literal=DATABASE_URL=postgresql://localhost:5432/mydb
```

Или через YAML:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DATABASE_URL: "postgresql://localhost:5432/mydb"
```

---

## Шаг 2: Инжекция в Pod

Используй ConfigMap в Pod манифесте:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  containers:
  - name: app
    image: my-app:latest
    envFrom:
    - configMapRef:
        name: app-config
```

---

</details>

<details>
<summary><b>⚡Создание ConfigMaps: императивный метод</b></summary>

---

## Два способа создания

Как и у любого другого объекта Kubernetes есть два способа создания:

- ✅ **Императивный метод** — без использования файла определения ConfigMap
- ✅ **Декларативный метод** — с использованием файла определения

---

## Метод 1: --from-literal

Пройдемся по первому методу, тут тоже можно действовать по-разному.

Если тебе не хочется создавать файлы-манифесты ConfigMaps, ты можешь просто использовать команду `kubectl create configmap` и указать необходимые аргументы.

Ты можешь напрямую указать пары ключ-значение в командной строке.

Чтобы создать configMap с заданными значениями, запусти команду `kubectl create configmap`, за которой имя configmap и параметр `--from-literal`.

Этот параметр `--from-literal` используется для указания пар ключ-значение в самой команде.

---

## Пример создания ConfigMap с --from-literal

В этом примере мы создаем configmap с именем `rockets-config` с парой значений ключа `ROCKET_SIZE=average`:

```bash
kubectl create configmap rockets-config --from-literal=ROCKET_SIZE=average
```

Можно добавить дополнительные пары ключ-значение, используя эту опцию несколько раз:

```bash
kubectl create configmap rockets-config \
  --from-literal=ROCKET_SIZE=average \
  --from-literal=ROCKET_COLOR=red \
  --from-literal=ROCKET_SPEED=fast
```

---

## Проверка созданного ConfigMap

```bash
# Просмотр ConfigMap
kubectl get configmap rockets-config

# Детальная информация
kubectl describe configmap rockets-config

# Просмотр данных
kubectl get configmap rockets-config -o yaml
```

---

## Метод 2: --from-file

Однако это будет сложно, если у тебя будет слишком много элементов конфигурации.

Для этого есть более удобный способ — ввод данных конфигурации через properties-файл.

Используй параметр `--from-file`, чтобы указать путь к файлу, содержащему необходимые данные.

Данные из этого файла будут прочитаны и сохранятся в созданном ConfigMap.

---

## Пример создания ConfigMap с --from-file

Создадим файл конфигурации:

```properties
# rocket.properties
ROCKET_SIZE=average
ROCKET_COLOR=red
ROCKET_SPEED=fast
ROCKET_FUEL=high_octane
```

Создадим ConfigMap из файла:

```bash
kubectl create configmap rockets-config --from-file=rocket.properties
```

Или указать ключ явно:

```bash
kubectl create configmap rockets-config --from-file=rocket-config=rocket.properties
```

---

## Создание ConfigMap из нескольких файлов

При необходимости в ConfigMap можно залить несколько файлов или целый каталог:

```bash
# Из нескольких файлов
kubectl create configmap app-config \
  --from-file=rocket.properties \
  --from-file=database.properties \
  --from-file=api.properties

# Из целого каталога
kubectl create configmap app-config --from-file=./config/
```

---

## Пример структуры каталога

```
config/
├── rocket.properties
├── database.properties
└── api.properties
```

Создание ConfigMap из каталога:

```bash
kubectl create configmap app-config --from-file=./config/
```

Каждый файл станет отдельным ключом в ConfigMap.

---

</details>

<details>
<summary><b>📄Создание ConfigMaps: декларативный метод</b></summary>

---

## Декларативный подход

Теперь давай рассмотрим декларативный подход.

Для этого мы создаем файл определения точно так же, как мы делали это для POD.

У файла есть `apiVersion`, `kind`, `metadata`, а вместо `spec` у нас есть `data`.

---

## Структура ConfigMap манифеста

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: rockets-config
data:
  ROCKET_SIZE: "average"
  ROCKET_COLOR: "red"
  ROCKET_SPEED: "fast"
```

ApiVersion — `v1`, kind — `ConfigMap`.

Под метаданными укажем название ConfigMap. Мы назовем его `rockets-config`.

Под данными укажем переменные конфигурации в формате ключ-значение.

---

## Применение ConfigMap

Запустим команду `kubectl apply` и укажем имя файла конфигурации:

```bash
kubectl apply -f rockets-config.yaml
```

Таким образом создается ConfigMap `rockets-config` с указанными нами значениями.

Мы можем создать столько ConfigMap, сколько нам нужно, это будет одинаково для всех.

---

## Примеры ConfigMaps для разных приложений

Ок, с примером ConfigMap для моего приложения ты уже знаком, здесь другой для mysql и еще один для redis.

Поэтому важно правильно называть ConfigMap, поскольку ты будешь использовать эти имена позже.

Мы создали ConfigMap с именем `rockets-config`, для небольшого сетапа это допустимо, но для более сложного лучше использовать название с смыслом в несколько слов.

---

### ConfigMap для MySQL

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
data:
  MYSQL_DATABASE: "myapp"
  MYSQL_USER: "appuser"
  MYSQL_ROOT_PASSWORD_FILE: "/run/secrets/mysql-root-password"
```

---

### ConfigMap для Redis

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-config
data:
  REDIS_HOST: "redis-service"
  REDIS_PORT: "6379"
  REDIS_DB: "0"
```

---

### ConfigMap для веб-приложения

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-app-config
data:
  ENVIRONMENT: "production"
  LOG_LEVEL: "info"
  API_URL: "https://api.example.com"
  MAX_CONNECTIONS: "100"
```

---

## Просмотр ConfigMaps

**Команда `kubectl describe configmaps` перечислит ConfigMaps и позволит заглянуть в раздел данных:**

```bash
# Список всех ConfigMaps
kubectl get configmaps

# Детальная информация о конкретном ConfigMap
kubectl describe configmap rockets-config

# Просмотр данных ConfigMap
kubectl get configmap rockets-config -o yaml
```

---

</details>

<details>
<summary><b>⚙️Kustomize: программная генерация ConfigMaps</b></summary>

---

## Что такое Kustomize?

Иногда тебе требуется программная генерация ConfigMaps по какому-то шаблону.

Например, при использовании в конвейере CI/CD.

Для разных сред у тебя может быть один шаблон и варианты кастомизации.

Для этих целей в Kubernetes механизм `configMapGenerator`.

---

## Использование configMapGenerator

Создай файл-шаблона `kustomization.yml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

configMapGenerator:
- name: rockets-config
  files:
  - rocket.properties
```

Сделай `kubectl apply -k`:

```bash
kubectl apply -k .
```

Эта команда возьмет данные из файла `rocket.properties` и создаст на основе этого файл-шаблона готовый configMap.

---

## Пример kustomization.yml

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: production

configMapGenerator:
- name: app-config
  files:
  - config/rocket.properties
  - config/database.properties
  literals:
  - ENVIRONMENT=production
  - LOG_LEVEL=info

resources:
- deployment.yaml
- service.yaml
```

У команды `kubectl kustomize` широкие возможности, почитай о ней в документации.

---

## Преимущества Kustomize

✅ **Шаблонизация** — один шаблон для разных сред
✅ **Автоматизация** — генерация в CI/CD
✅ **Версионирование** — контроль изменений
✅ **Масштабируемость** — легко управлять множеством ConfigMaps

---

</details>

<details>
<summary><b>💉Использование ConfigMaps в Pods: envFrom</b></summary>

---

## Шаг 2: Инжекция ConfigMap в Pod

Итак, мы создали ConfigMap, теперь давай перейдем к шагу 2, и вставим ее в POD с приложением.

У меня есть простой файл определения POD, который запускает мое простое веб-приложение демонстрирующее ракеты.

---

## Свойство envFrom

Для ввода в контейнер переменной среды добавим новое свойство в секцию container названием `envFrom`.

Свойство `envFrom` представляет собой list, поэтому мы можем передать столько переменных среды, сколько требуется.

Каждый элемент в этом list соответствует элементу ConfigMap.

Укажем имя созданной ранее ConfigMap.

Вот так мы инжектируем эту конкретную ConfigMap.

---

## Пример использования envFrom

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: rocket-app
spec:
  containers:
  - name: app
    image: rocket-app:latest
    envFrom:
    - configMapRef:
        name: rockets-config
```

При создании файла определения POD теперь создается веб-приложение с средним размером ракеты, но если мы изменим значение в ConfigMap и пересоздадим POD, то вывод приложения изменится.

---

## Как это работает

Все ключи из ConfigMap становятся переменными окружения:

**ConfigMap:**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: rockets-config
data:
  ROCKET_SIZE: "average"
  ROCKET_COLOR: "red"
  ROCKET_SPEED: "fast"
```

В Pod будут доступны:

```bash
ROCKET_SIZE=average
ROCKET_COLOR=red
ROCKET_SPEED=fast
```

---

## Использование нескольких ConfigMaps

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: rocket-app
spec:
  containers:
  - name: app
    image: rocket-app:latest
    envFrom:
    - configMapRef:
        name: rockets-config
    - configMapRef:
        name: mysql-config
    - configMapRef:
        name: redis-config
```

---

## Комбинация env и envFrom

**Можно комбинировать `env` и `envFrom`:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: rocket-app
spec:
  containers:
  - name: app
    image: rocket-app:latest
    env:
    - name: POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    envFrom:
    - configMapRef:
        name: rockets-config
```

---

## Важно: обновление ConfigMap

⚠️ **Важно:** при изменении ConfigMap нужно пересоздать Pod, чтобы изменения вступили в силу (если не используешь Volumes).

```bash
# Обновить ConfigMap
kubectl apply -f rockets-config.yaml

# Пересоздать Pod
kubectl delete pod rocket-app
kubectl apply -f rocket-app.yaml
```

---

</details>

<details>
<summary><b>🔀Другие способы использования ConfigMaps</b></summary>

---

## Использование ConfigMaps как отдельных переменных

Мы только что увидели использование ConfigMaps для ввода переменных окружения.

Существуют и другие способы внедрения данных конфигурации в PODs, например как отдельную переменную среды:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: rocket-app
spec:
  containers:
  - name: app
    image: rocket-app:latest
    env:
    - name: ROCKET_SIZE
      valueFrom:
        configMapKeyRef:
          name: rockets-config
          key: ROCKET_SIZE
```

Этот способ был рассмотрен в предыдущей лекции (K-09-4).

---

## Использование ConfigMaps через Volumes

Или можем подключить много данных в виде файлов с помощью механизма томов — volumes.

Считается что использование volumes более секьюрно и удобно, т.к. при изменении ConfigMap данные в томе тоже обновятся сами.

---

## Пример использования ConfigMap как Volume

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: rocket-app
spec:
  containers:
  - name: app
    image: rocket-app:latest
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: rockets-config
```

Все ключи из ConfigMap будут доступны как файлы в `/etc/config/`.

---

## Использование отдельных ключей ConfigMap

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: rocket-app
spec:
  containers:
  - name: app
    image: rocket-app:latest
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: rockets-config
      items:
      - key: ROCKET_SIZE
        path: rocket-size.txt
      - key: ROCKET_COLOR
        path: rocket-color.txt
```

---

## Преимущества использования Volumes

✅ **Автоматическое обновление** — при изменении ConfigMap данные обновляются автоматически
✅ **Безопасность** — данные не видны в переменных окружения процесса
✅ **Большие конфигурации** — удобно для больших файлов конфигурации
✅ **Файловая структура** — можно создать иерархию файлов

---

## Когда использовать envFrom vs Volumes

| Подход | Использование | Преимущества |
|--------|---------------|--------------|
| **envFrom** | Переменные окружения | Простота, доступ через `process.env` |
| **Volumes** | Файлы конфигурации | Автообновление, большие файлы, безопасность |

---

</details>

<details>
<summary><b>💡Практические примеры</b></summary>

---

## Пример 1: Полный цикл создания и использования

### Шаг 1: Создание ConfigMap (императивный метод)

```bash
kubectl create configmap app-config \
  --from-literal=ENVIRONMENT=production \
  --from-literal=LOG_LEVEL=info \
  --from-literal=API_URL=https://api.example.com
```

---

### Шаг 2: Использование в Pod

```yaml
# app-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: my-app:latest
    envFrom:
    - configMapRef:
        name: app-config
```

```bash
kubectl apply -f app-pod.yaml
```

---

## Пример 2: Декларативный метод

### Создание ConfigMap

```yaml
# app-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  ENVIRONMENT: "production"
  LOG_LEVEL: "info"
  API_URL: "https://api.example.com"
  MAX_CONNECTIONS: "100"
```

```bash
kubectl apply -f app-config.yaml
```

---

### Использование в Pod

```yaml
# app-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: my-app:latest
    envFrom:
    - configMapRef:
        name: app-config
```

---

## Пример 3: ConfigMap из файла

### Создание файла конфигурации

```properties
# config.properties
DATABASE_HOST=postgres
DATABASE_PORT=5432
DATABASE_NAME=myapp
```

### Создание ConfigMap

```bash
kubectl create configmap app-config --from-file=config.properties
```

### Использование в Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: my-app:latest
    envFrom:
    - configMapRef:
        name: app-config
```

---

## Пример 4: ConfigMap как Volume

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-config
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    volumeMounts:
    - name: nginx-config
      mountPath: /etc/nginx/conf.d
  volumes:
  - name: nginx-config
    configMap:
      name: nginx-config
```

---

</details>

<details>
<summary><b>🔍Проверка и отладка</b></summary>

---

## Просмотр переменных окружения в Pod

Так что переходи туда и тренируй просмотр и траблешутинг переменных среды в Kubernetes.

```bash
# Просмотр переменных окружения в запущенном Pod
kubectl exec <pod-name> -- env

# Просмотр конкретной переменной
kubectl exec <pod-name> -- printenv ROCKET_SIZE

# Просмотр всех переменных с фильтром
kubectl exec <pod-name> -- env | grep ROCKET
```

---

## Проверка ConfigMap

```bash
# Список всех ConfigMaps
kubectl get configmaps

# Детальная информация
kubectl describe configmap rockets-config

# Просмотр в YAML формате
kubectl get configmap rockets-config -o yaml

# Просмотр в JSON формате
kubectl get configmap rockets-config -o json
```

---

## Проверка Pod

```bash
# Описание Pod
kubectl describe pod <pod-name>

# Логи Pod
kubectl logs <pod-name>

# Проверка событий
kubectl get events --sort-by='.lastTimestamp'
```

---

## Отладка проблем

Если переменные окружения не работают:

1. ✅ Проверь, что ConfigMap создан: `kubectl get configmap`
2. ✅ Проверь имя ConfigMap в Pod манифесте
3. ✅ Проверь, что Pod пересоздан после изменения ConfigMap
4. ✅ Проверь логи Pod: `kubectl logs <pod-name>`
5. ✅ Проверь описание Pod: `kubectl describe pod <pod-name>`

---

</details>

---

## Резюме

✅ **Создание ConfigMaps:**
- **Императивный метод:** `kubectl create configmap --from-literal` или `--from-file`
- **Декларативный метод:** YAML манифест с `apiVersion`, `kind`, `metadata`, `data`
- **Kustomize:** `configMapGenerator` для программной генерации

✅ **Использование ConfigMaps в Pods:**
- `envFrom.configMapRef` — все переменные из ConfigMap
- `valueFrom.configMapKeyRef` — отдельная переменная (из предыдущей лекции)
- Volumes — для файлов конфигурации (автообновление)

✅ **Преимущества ConfigMaps:**
- Централизованное управление конфигурацией
- Переиспользование между Pods
- Легкое обновление
- Разделение конфигурации и кода

✅ **Практика:**
- Используй осмысленные имена для ConfigMaps
- Комбинируй `env` и `envFrom` при необходимости
- Используй Volumes для больших конфигураций и автообновления
- Проверяй переменные через `kubectl exec`
- Пересоздавай Pod после изменения ConfigMap (если не используешь Volumes)

> 💡 **Совет:** Используй ConfigMaps для централизованного управления конфигурацией. Это упрощает обновление и переиспользование настроек между разными Pods. Помни, что при изменении ConfigMap нужно пересоздать Pod, чтобы изменения вступили в силу (если не используешь Volumes, которые обновляются автоматически). Тренируй просмотр и траблешутинг переменных среды в Kubernetes.

---

