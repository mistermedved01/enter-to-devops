[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [🎛️ K-02-Master-компоненты](../../README.md#-k-02-master-компоненты)

---

# 🎛️K-02-4-Master-Component-Kube-Scheduler
>kube-scheduler - планировщик, распределяет Pod'ы по нодам на основе ресурсов и политик

---

<details>
<summary><b>🎯Роль kube-scheduler</b></summary>

---

## Аналогия с космическим крановщиком

**kube-scheduler** - это логист кластера, который:

- ✅ **Принимает решения** о размещении Pod'ов
- ❌ **Не запускает** Pod'ы (это делает kubelet)
- ✅ **Анализирует** характеристики Pod'ов и нод
- ✅ **Оптимизирует** распределение нагрузки

## Почему отдельный планировщик?

```
# Капитаны (kubelet) умеют запускать контейнеры,
# но логистику лучше доверить специалисту (scheduler)

kubelet = капитан корабля
scheduler = опытный логист станции
```

**Задачи планировщика:**
- 📊 Учет ресурсов нод (CPU, память, GPU)
- 🎯 Учет специализации нод (SSD, GPU, зоны)
- 🗺️ Оптимизация маршрутов и расположения
- ⚖️ Балансировка нагрузки в кластере

---

</details>

<details>
<summary><b>🔧Процесс планирования</b></summary>

---

## Двухэтапный алгоритм

### Этап 1: Фильтрация нод
```
# Отсеиваем ноды, которые не подходят
Все ноды → Фильтрация → Подходящие ноды
    ↓           ↓             ↓
 [node1]    Ресурсы CPU?    [node3]
 [node2] ──× Не хватает ──→ [node4] 
 [node3]    Ресурсы CPU?    
 [node4]                    [node5]
```

**Критерии фильтрации:**
- 🔹 Достаточно ли CPU/памяти?
- 🔹 Соответствуют ли taints/tolerations?
- 🔹 Подходит ли node selector?
- 🔹 Доступны ли порты?

### Этап 2: Ранжирование нод
```
# Оцениваем подходящие ноды по шкале 0-10
Подходящие ноды → Ранжирование → Лучшая нода
     ↓               ↓             ↓
   [node3]        node3: 8/10    [node4]
   [node4] ─────→ node4: 9/10 ──→
   [node5]        node5: 7/10
```

**Критерии ранжирования:**
- 💯 Свободные ресурсы после размещения
- 📍 Расположение и зоны доступности
- 🔗 Affinity/anti-affinity правила
- ⚖️ Баланс нагрузки в кластере

---

</details>

<details>
<summary><b>📊Пример распределения</b></summary>

---

## Исходные данные

### Pod'ы для размещения:
```
Pod A: требует 2 CPU, 4GB памяти
Pod B: требует 4 CPU, 2GB памяти  
Pod C: требует 10 CPU, 8GB памяти  ← "жирный" Pod
```

### Доступные ноды:
```
Node 1: 4 CPU свободно, 8GB памяти
Node 2: 6 CPU свободно, 4GB памяти
Node 3: 16 CPU свободно, 16GB памяти
-кod

## Процесс для Pod C (10 CPU)

### Фильтрация:
```
Node 1: 4 CPU < 10 CPU → ❌ Отсеян
Node 2: 6 CPU < 10 CPU → ❌ Отсеян
Node 3: 16 CPU ≥ 10 CPU → ✅ Прошел
```

### Ранжирование:
```
Node 3: 16 CPU - 10 CPU = 6 CPU свободно
Рейтинг: 9/10 (много свободных ресурсов)
```

**Результат:** Pod C назначается на Node 3

---

</details>

<details>
<summary><b>🛠️Установка и настройка</b></summary>

---

## Скачивание и установка

```
# Скачать бинарник kube-scheduler
wget https://github.com/kubernetes/kubernetes/releases/download/v1.28.0/kubernetes-server-linux-amd64.tar.gz

# Распаковать и установить
tar -xzf kubernetes-server-linux-amd64.tar.gz
cd kubernetes/server/bin
cp kube-scheduler /usr/local/bin/
```

## Базовая конфигурация

```
kube-scheduler \
  --kubeconfig=/etc/kubernetes/scheduler.conf \
  --bind-address=0.0.0.0 \
  --leader-elect=true \
  --config=/etc/kubernetes/scheduler-config.yaml
```

## Ключевые параметры

| Параметр | Назначение |
|----------|------------|
| `--kubeconfig` | Конфиг для доступа к API |
| `--leader-elect` | Выбор лидера для HA |
| `--config` | Файл конфигурации планировщика |
| `--bind-address` | Адрес для прослушивания |

---

</details>

<details>
<summary><b>🔍Просмотр конфигурации</b></summary>

---

## Для кластеров kubeadm

```
# kube-scheduler работает как Pod
kubectl get pods -n kube-system | grep scheduler

# Посмотреть манифест Pod
cat /etc/kubernetes/manifests/kube-scheduler.yaml

# Или через kubectl
kubectl get pod kube-scheduler-node1 -n kube-system -o yaml
```

## Для ручной установки

```
# Посмотреть systemd service
cat /etc/systemd/system/kube-scheduler.service

# Или посмотреть запущенный процесс
ps aux | grep kube-scheduler

# Фильтрация по процессу
ps -ef | grep kube-scheduler | grep -v grep
```

## Расположение файлов

```
# kubeadm кластер
/etc/kubernetes/manifests/kube-scheduler.yaml
/etc/kubernetes/scheduler.conf

# Ручная установка  
/etc/systemd/system/kube-scheduler.service
/etc/kubernetes/scheduler-config.yaml
```

---

</details>

<details>
<summary><b>⚙️Расширенные возможности</b></summary>

---

## Настраиваемые политики

```
# Пример конфигурации планировщика
apiVersion: kubescheduler.config.k8s.io/v1beta1
kind: KubeSchedulerConfiguration
profiles:
  - schedulerName: default-scheduler
    plugins:
      score:
        enabled:
        - name: NodeResourcesFit
        - name: NodeAffinity
        - name: InterPodAffinity
```

## Кастомные планировщики

```
# Можно написать свой планировщик
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  schedulerName: my-custom-scheduler  # Использовать кастомный планировщик
  containers:
  - name: nginx
    image: nginx
```

---

</details>

<details>
<summary><b>🔮Что будет в курсе дальше</b></summary>

---

## Подробное изучение планирования

### Критерии планирования:
- **Taints and Tolerations** - ограничения размещения
- **Node Affinity** - предпочтения к нодам
- **Pod Affinity/Anti-Affinity** - правила совместного размещения
- **Resource Limits** - ограничения ресурсов

### Продвинутые темы:
- **Multiple Schedulers** - несколько планировщиков
- **Custom Scheduler** - написание своего планировщика
- **Scheduler Profiles** - профили планирования
- **Performance Tuning** - оптимизация производительности

---

</details>

<details>
<summary><b>🎯Ключевые выводы</b></summary>

---

## Основные принципы

1. **📌 Решение, а не исполнение** - scheduler решает куда, kubelet запускает
2. **📌 Двухэтапный процесс** - фильтрация + ранжирование
3. **📌 Множество критериев** - ресурсы, политики, affinity
4. **📌 Настраиваемость** - можно кастомизировать и расширять
5. **📌 Высокая доступность** - поддержка leader election

## Процесс в деталях

```
Новый Pod → Scheduler → Фильтрация → Ранжирование → Выбор ноды
     ↓          ↓           ↓           ↓           ↓
   Создан    Анализ      Отсев      Оценка     Назначение
   пользователем   неподходящих   подходящих   лучшей ноде
```

> 🚀 **Дальше:** Рассмотрим kubelet - агент на рабочих нодах, который исполняет решения scheduler.

---

</details>

---