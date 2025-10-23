[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [⚙️ K-06-Управление](../../README.md#-k-06-управление)

# 📚K-06-2-kubectl-apply
>kubectl apply - внутренняя механика команды: три конфигурации, слияние изменений и управление состоянием объектов Kubernetes

---

<details>
<summary><b>🎯Три конфигурации kubectl apply</b></summary>

---

## Как работает команда apply внутри

```
# kubectl apply использует 3 конфигурации:
1. Локальный файл (local)    → Что мы хотим
2. Живая конфигурация (live) → Что есть в кластере  
3. Последняя примененная (last-applied) → Что было применено ранее
```

## Визуализация процесса

```
# Процесс принятия решений:
Локальный файл ←→ Последняя примененная ←→ Живая конфигурация
       ↓                  ↓                      ↓
   Желаемое           История              Фактическое
   состояние         изменений             состояние
```

---

</details>

<details>
<summary><b>🔧Создание объекта через apply</b></summary>

---

## Первое применение

```
# Объект не существует
kubectl apply -f deployment.yaml

# Процесс:
1. ✅ Создается объект в кластере
2. ✅ Локальная конфигурация сохраняется как last-applied
3. ✅ Объект получает аннотацию:
   kubectl.kubernetes.io/last-applied-configuration: '{"apiVersion":...}'
```

## Что хранится в аннотации

```
# Аннотация last-applied-configuration
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {
        "apiVersion": "apps/v1",
        "kind": "Deployment",
        "metadata": {
          "name": "nginx",
          "namespace": "default"
        },
        "spec": {
          "replicas": 3,
          "template": {
            "spec": {
              "containers": [{
                "name": "nginx",
                "image": "nginx:1.19"
              }]
            }
          }
        }
      }
```

---

</details>

<details>
<summary><b>📝Декларативные манифесты</b></summary>

---

## Работа с файлами

```
# Создание/обновление через apply
kubectl apply -f deployment.yaml

# Применение всей директории
kubectl apply -f k8s/

# Применение нескольких файлов
kubectl apply -f deployment.yaml -f service.yaml -f configmap.yaml

# Просмотр различий
kubectl diff -f deployment.yaml
```

## Что значит "применить всю директорию"

```
# Структура папки k8s/:
k8s/
├── deployment.yaml    # Deployment манифест
├── service.yaml       # Service манифест  
├── configmap.yaml     # ConfigMap манифест
├── secret.yaml        # Secret манифест
└── namespace.yaml     # Namespace манифест

# Одна команда применяет ВСЕ файлы в директории:
kubectl apply -f k8s/
```

**Как это работает:**
- ✅ **Рекурсивно** обрабатывает все файлы в директории
- ✅ **Автоматически определяет** порядок создания (namespaces first)
- ✅ **Обрабатывает все поддерживаемые форматы** (.yaml, .yml, .json)
- ✅ **Создает/обновляет все объекты** за одну команду

## Практический пример

```
# Создаем структуру проекта
mkdir k8s-manifests
cd k8s-manifests

# Создаем манифесты
vim k8s/namespace.yaml
vim k8s/deployment.yaml  
vim k8s/service.yaml
vim k8s/configmap.yaml

# Применяем ВСЕ разом
kubectl apply -f k8s/

# Результат: созданы все объекты из всех файлов
```

## Порядок обработки

```text
# Kubernetes автоматически определяет порядок:
1. Namespaces
2. Custom Resource Definitions (CRDs)  
3. Storage Classes
4. Persistent Volumes
5. ConfigMaps, Secrets
6. Services, Deployments, StatefulSets
7. Pods, Jobs, CronJobs

# Не нужно беспокоиться о зависимостях!
```

---

</details>

<details>
<summary><b>🔄Обновление объекта через apply</b></summary>

---

## Сценарий: обновление образа

```
# Локальный файл (новый)
image: nginx:1.20

# Last Applied (старый)  
image: nginx:1.19

# Live Config (текущий)
image: nginx:1.19

# Решение apply: обновить образ до 1.20
```

## Сценарий: удаление поля

```
# Локальный файл (метка удалена)
metadata:
  name: nginx
  # labels: УДАЛЕНО!

# Last Applied (была метка)
metadata:
  name: nginx
  labels:
    app: nginx

# Live Config (есть метка)
metadata:
  name: nginx
  labels:
    app: nginx

# Решение apply: удалить метку из live config
```

## Алгоритм принятия решений

```
# Правила слияния изменений:
1. Поле есть в local, но нет в last-applied → ДОБАВИТЬ
2. Поле есть в last-applied, но нет в local → УДАЛИТЬ  
3. Поле отличается в local и last-applied → ОБНОВИТЬ
4. Поле есть только в live → СОХРАНИТЬ (не трогать)
```

---

</details>

<details>
<summary><b>📊Практические примеры</b></summary>

---

## Пример 1: Добавление поля

```
# Было (last-applied):
spec:
  replicas: 3

# Стало (local):
spec:
  replicas: 5
  minReadySeconds: 30  ← НОВОЕ ПОЛЕ

# Результат: replicas обновлено до 5, minReadySeconds добавлено
```

## Пример 2: Удаление поля

```
# Было (last-applied):
metadata:
  labels:
    app: nginx
    version: "1.0"   ← ЭТО ПОЛЕ УДАЛЯЕТСЯ

# Стало (local):
metadata:
  labels:
    app: nginx

# Результат: метка version удалена из объекта
```

## Пример 3: Конфликтующие изменения

```
# Last Applied: replicas: 3
# Local: replicas: 5
# Live: replicas: 10  (изменено через kubectl scale)

# Результат: replicas устанавливается в 5 (из local)
# Live значение перезаписывается!
```

---

</details>

<details>
<summary><b>🚫Проблемы смешанного подхода</b></summary>

---

## Почему нельзя смешивать команды

```
# ПЛОХО: смешиваем apply и imperative команды
kubectl apply -f deployment.yaml    # Создает last-applied
kubectl scale deployment --replicas=5  # Меняет live config
kubectl apply -f deployment.yaml    # last-applied ≠ live config!

# Результат: конфигурационный дрифт и неожиданные поведения
```

## Что происходит при смешивании

```
# После kubectl scale:
Last Applied: replicas: 3
Local: replicas: 3  
Live: replicas: 5

# При следующем apply:
- Last Applied говорит "должно быть 3"
- Local говорит "должно быть 3" 
- Live сейчас "5"
- Результат: replicas вернется к 3!
```

---

</details>

<details>
<summary><b>🔍Просмотр конфигураций</b></summary>

---

## Как посмотреть аннотации

```
# Посмотреть last-applied аннотацию
kubectl get deployment nginx -o yaml | grep -A 20 last-applied

# Или через describe
kubectl describe deployment nginx

# Посмотреть все аннотации
kubectl get deployment nginx -o jsonpath='{.metadata.annotations}'
```

## Команда diff

```
# Посмотреть что изменится перед применением
kubectl diff -f deployment.yaml

# Показать различия между конфигурациями
kubectl diff -f deployment.yaml --server-side
```

---

</details>

<details>
<summary><b>🛠️Практические команды</b></summary>

---

## Управление last-applied конфигурацией

```
# Принудительно обновить last-applied
kubectl apply -f deployment.yaml --server-side

# Просмотреть текущую last-applied
kubectl apply view-last-applied -f deployment.yaml

# Очистить last-applied аннотацию
kubectl apply -f deployment.yaml --overwrite=false
```

## Восстановление конфигурации

```
# Если last-appized испорчена:
kubectl replace -f deployment.yaml --save-config

# Или пересоздать аннотацию
kubectl apply -f deployment.yaml --force-conflicts
```

---

</details>

<details>
<summary><b>🎯Best Practices</b></summary>

---

## Рекомендации по использованию

```
✅ Всегда используйте kubectl apply для декларативного управления
✅ Храните манифесты в системе контроля версий
✅ Используйте kubectl diff перед apply
✅ Не смешивайте imperative и declarative команды
✅ Используйте --server-side для больших конфигураций
```

## Чего избегать

```
❌ Не используйте kubectl edit после apply
❌ Не используйте kubectl scale с apply
❌ Не изменяйте объекты напрямую через API
❌ Не удаляйте last-applied аннотации вручную
❌ Не игнорируйте конфигурационный дрифт
```

---

</details>

<details>
<summary><b>📚Ключевые выводы</b></summary>

---

## Как работает механизм

```
1. Last-applied хранится в аннотациях объекта
2. Apply использует 3-way merge (local, last-applied, live)
3. Механизм запоминает историю изменений
4. Позволяет безопасно удалять поля из конфигурации
5. Гарантирует идемпотентность операций
```

## Почему это важно

```
✅ Безопасное удаление полей из конфигураций
✅ Консистентность между желаемым и фактическим состоянием
✅ Возможность отката изменений
✅ Предсказуемое поведение при многократном применении
✅ Поддержка GitOps подходов
```

> 💡 **Важно:** Механизм last-applied конфигурации - это основа декларативного управления в Kubernetes. Понимание его работы помогает избежать многих проблем в продакшене.

---

</details>