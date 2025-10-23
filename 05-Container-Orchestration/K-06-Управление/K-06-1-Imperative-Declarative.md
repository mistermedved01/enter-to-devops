[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [⚙️ K-06-Управление](../../README.md#-k-06-управление)

# 📚K-06-1-Imperative-Declarative
>Императивный vs декларативный подходы управления Kubernetes: команды vs манифесты, когда и какой использовать на практике

---

<details>
<summary><b>🎯Аналогия: космическое путешествие</b></summary>

---

## Императивный подход

```
# Мы даем пошаговые инструкции:
1. Летим до Марса
2. Становимся на его орбиту  
3. Ждем подходящего времени
4. Используем Марс для гравитационного маневра
5. Проходим пояс астероидов
6. В определенное время разгоняем корабль
7. В определенное время тормозим
8. Выходим на орбиту Сатурна

# Мы говорим "КАК" достичь цели
```

## Декларативный подход

```
# Мы объявляем желаемое состояние:
- Место назначения: Сатурн
- Дата прибытия: конец октября

# Система сама определяет оптимальный путь
# Мы говорим "ЧТО" хотим получить
```

---

</details>

<details>
<summary><b>🏗️Применение в Kubernetes</b></summary>

---

## Императивный подход (Imperative)

```
# Команды, которые говорят КАК делать:
kubectl run nginx --image=nginx
kubectl create deployment web --image=nginx
kubectl expose deployment web --port=80
kubectl scale deployment web --replicas=3
kubectl set image deployment/web nginx=nginx:1.21
```

## Декларативный подход (Declarative)

```
# Файлы, которые описывают ЧТО хотим:
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
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
        image: nginx:1.21

# Применяем желаемое состояние
kubectl apply -f deployment.yaml
```

---

</details>

<details>
<summary><b>🛠️Императивные команды</b></summary>

---

## Создание объектов

```
# Pod
kubectl run nginx-pod --image=nginx --port=80

# Deployment
kubectl create deployment web --image=nginx --replicas=3

# Service
kubectl expose deployment web --port=80 --target-port=80

# Namespace
kubectl create namespace development
```

## Изменение объектов

```
# Масштабирование
kubectl scale deployment web --replicas=5

# Обновление образа
kubectl set image deployment/web nginx=nginx:1.21

# Редактирование в реальном времени
kubectl edit deployment web
```

## Плюсы и минусы

```
✅ Быстро для простых задач
✅ Не нужны YAML файлы
✅ Хорошо для экзамена

❌ Сложно для продвинутых конфигураций
❌ Нет истории изменений
❌ Конфигурационный дрифт
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

# Просмотр различий
kubectl diff -f deployment.yaml
```

## Пример манифеста

```
apiVersion: v1
kind: Pod
metadata:
  name: multi-container-pod
spec:
  containers:
  - name: nginx
    image: nginx:1.21
    env:
    - name: ENVIRONMENT
      value: "production"
    ports:
    - containerPort: 80
  - name: log-agent
    image: fluentd:latest
```

## Плюсы и минусы

+кod
✅ Версионность (Git)
✅ Воспроизводимость
✅ Сложные конфигурации
✅ Контроль изменений

❌ Требует YAML файлов
❌ Медленнее для простых задач
❌ Кривая обучения
```

---

</details>

<details>
<summary><b>⚠️Проблема конфигурационного дрифта</b></summary>

---

## Пример проблемы

```
# 1. Создаем Pod из файла
kubectl apply -f pod.yaml  # image: nginx:1.20

# 2. Редактируем напрямую
kubectl edit pod my-pod    # меняем на image: nginx:1.21

# 3. Проблема: файл pod.yaml все еще содержит nginx:1.20
# При следующем apply изменения потеряются!
```

## Решение

```
# Всегда обновляйте файлы манифестов!
1. Редактируйте локальный файл
2. Применяйте изменения
3. Коммитьте в Git

# Правильный workflow:
nano deployment.yaml        # Редактируем файл
kubectl apply -f deployment.yaml  # Применяем
git add deployment.yaml     # Сохраняем историю
git commit -m "Update nginx to 1.21"
```

---

</details>

<details>
<summary><b>🎯Рекомендации для экзамена CKA/CKAD</b></summary>

---

## Когда использовать императивный подход

```
✅ Простые Pod'ы
kubectl run nginx --image=nginx

✅ Базовые Deployment'ы  
kubectl create deployment web --image=nginx --replicas=2

✅ Создание Services
kubectl expose deployment web --port=80

✅ Быстрое масштабирование
kubectl scale deployment web --replicas=5
```

## Когда использовать декларативный подход

```
✅ Сложные конфигурации (многоконтейнерные Pod'ы)
✅ Переменные окружения, volumes
✅ Продвинутые Deployment'ы
✅ Когда легко ошибиться в командах
✅ Для воспроизводимости изменений
```

## Стратегия на экзамене

```
# Быстрые команды для простых задач:
kubectl run...
kubectl create...
kubectl expose...

# Файлы для сложных конфигураций:
vim deployment.yaml
kubectl apply -f deployment.yaml

# Редактирование существующих объектов:
kubectl edit deployment/name  # Быстрое исправление
```

---

</details>

<details>
<summary><b>🔧Практические примеры</b></summary>

---

## Императивный: быстрое создание

```
# Создать Namespace, Deployment и Service
kubectl create namespace test
kubectl create deployment app --image=nginx -n test
kubectl expose deployment app --port=80 -n test
kubectl scale deployment app --replicas=3 -n test

# Время выполнения: ~30 секунд
```

## Декларативный: сложная конфигурация

```
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: complex-app
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: complex
  template:
    metadata:
      labels:
        app: complex
    spec:
      containers:
      - name: web
        image: nginx:1.21
        env:
        - name: DB_HOST
          value: "mysql-service"
        - name: REDIS_HOST  
          value: "redis-service"
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"

# Применяем
kubectl apply -f deployment.yaml
```

---

</details>

<details>
<summary><b>📊Сравнительная таблица</b></summary>

---

| Аспект | Императивный | Декларативный |
|--------|-------------|---------------|
| **Подход** | "Как сделать" | "Что хотим получить" |
| **Скорость** | 🚀 Быстро | ⏱️ Медленнее |
| **Сложность** | Простые задачи | Сложные конфигурации |
| **История** | Нет версионности | Git-контроль |
| **Экзамен** | Быстрые ответы | Точные конфигурации |
| **Продакшен** | Не рекомендуется | ✅ Рекомендуется |

---

</details>

<details>
<summary><b>🎯Итоговые рекомендации</b></summary>

---

## Best Practices

```
# Для продакшена:
✅ Всегда используйте декларативный подход
✅ Храните манифесты в Git
✅ Используйте kubectl apply
✅ Избегайте kubectl edit

# Для экзамена:
✅ Императивный для простых задач
✅ Декларативный для сложных конфигураций  
✅ kubectl edit для быстрых исправлений
✅ Практикуйте оба подхода
```

## Ключевые команды для запоминания

```
# Императивные (запомнить для экзамена):
kubectl run, create, expose, scale, set image

# Декларативные (лучшая практика):
kubectl apply, diff, delete -f

# Универсальные:
kubectl get, describe, logs, exec
```

> 💡 **Совет для экзамена:** Начинайте с императивных команд для экономии времени, но будьте готовы перейти к YAML файлам для сложных задач.

---

</details>