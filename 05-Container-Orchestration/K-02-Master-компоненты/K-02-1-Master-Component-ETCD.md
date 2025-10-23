[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [🎛️ K-02-Master-компоненты](../../README.md#-k-02-master-компоненты)

---

# 🎛️K-02-1-Master-Component-ETCD
>etcd - распределенная база данных кластера Kubernetes для хранения состояния всех объектов

---

<details>
<summary><b>🎯Что такое ETCD?</b></summary>

---

## Основные понятия

**ETCD** - это надежное распределенное хранилище типа "ключ-значение", которое характеризуется:
- ✅ **Простота** - минималистичный API
- ✅ **Безопасность** - встроенная поддержка TLS
- ✅ **Скорость** - оптимизировано для быстрых операций
- ✅ **Распределенность** - отказоустойчивая архитектура

## Хранилище ключ-значение vs Реляционные БД

### Реляционные БД (SQL)
```
Таблица: users
id  | name  | age
----|-------|----
1   | Alice | 25
2   | Bob   | 30
```

### NoSQL (ключ-значение)
```
user:1 → {"name": "Alice", "age": 25}
user:2 → {"name": "Bob", "age": 30}
config:app → {"version": "1.0", "debug": true}
```

**Ключевые различия:**
- **NoSQL** - простой доступ по ключу, нет дубликатов ключей
- **SQL** - сложные запросы, связи между таблицами
- **NoSQL** идеально подходит для конфигураций и быстрого доступа

---

</details>

<details>
<summary><b>🛠️Установка и запуск ETCD</b></summary>

---

## Установка

1. **Скачивание с GitHub**
```
# Для Linux
wget https://github.com/etcd-io/etcd/releases/download/v3.5.0/etcd-v3.5.0-linux-amd64.tar.gz
tar -xvf etcd-v3.5.0-linux-amd64.tar.gz
cd etcd-v3.5.0-linux-amd64
```

2. **Запуск сервера**
```
./etcd
# Сервис запускается на порту 2379
```

## Проверка работы

```
# Проверить что etcd слушает на порту 2379
netstat -tulpn | grep 2379

# Или используя ss
ss -tulpn | grep 2379
```

---

</details>

<details>
<summary><b>🔧Работа с etcdctl</b></summary>

---

## Основные команды

### Запись данных
```
# Сохранить пару ключ-значение
etcdctl put key1 "value1"
etcdctl put app/config '{"debug": true, "port": 8080}'
```

### Чтение данных
```
# Получить значение по ключу
etcdctl get key1

# Получить все ключи
etcdctl get --prefix ""

# Получить ключи с префиксом
etcdctl get --prefix "app/"
```

### Удаление данных
```
# Удалить конкретный ключ
etcdctl del key1

# Удалить все ключи с префиксом
etcdctl del --prefix "app/"
```

## Дополнительные команды

```
# Просмотр всех доступных команд
etcdctl --help

# Проверка здоровья кластера
etcdctl endpoint health

# Просмотр метрик
etcdctl endpoint status
```

---

</details>

<details>
<summary><b>🔮Продвинутые темы (будут позже)</b></summary>

---

## Что будет рассмотрено в следующих частях:

### Высокая доступность
- Распределенная архитектура ETCD
- Режимы работы клиентов
- Протокол RAFT для консенсуса

### Проблемы и решения
- "Split-brain" (раздвоение личности) кластеров
- Best practices по количеству узлов
- Восстановление после сбоев

### Безопасность
- Настройка TLS
- Аутентификация и авторизация
- RBAC для ETCD

---

</details>

<details>
<summary><b>🎯ETCD в Kubernetes</b></summary>

---

## Роль ETCD в Kubernetes

ETCD используется как **единственный источник истины** для Kubernetes:

- Хранит состояние всех ресурсов (Pods, Services, Deployments)
- Сохраняет конфигурацию кластера
- Обеспечивает согласованность данных между компонентами

## Пример данных в Kubernetes

```
/registry/pods/default/my-pod → { Pod manifest }
/registry/services/default/frontend → { Service manifest }
/registry/configmaps/default/app-config → { ConfigMap data }
```

> 💡 **Важно:** Без ETCD Kubernetes не может функционировать - это критически важный компонент кластера.

---

</details>

<details>
<summary><b>💡Ключевые выводы</b></summary>

---

1. **📌 ETCD** - распределенное хранилище ключ-значение
2. **📌 Простота** - минималистичный API для быстрых операций
3. **📌 Надежность** - отказоустойчивая архитектура
4. **📌 Критический компонент** Kubernetes
5. **📌 Легкость использования** - простые команды etcdctl

> 🚀 **Дальше:** В следующих частях рассмотрим высокую доступность ETCD и протокол RAFT.

</details>

---