[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [🎛️ K-02-Master-компоненты](../../README.md#-k-02-master-компоненты)

---

# 🎛️K-02-3-Master-Component-Kube-Controller-Manager
>kube-controller-manager - менеджер контроллеров, управляет состоянием кластера и поддерживает желаемое состояние

---

<details>
<summary><b>🎯Что такое Controller Manager?</b></summary>

---

## Аналогия с космической станцией

Представьте **kube-controller-manager** как флот специализированных кораблей:

- **🛸 Сканирующие корабли** - мониторят состояние грузовых кораблей
- **🛸 Аварийные бригады** - реагируют на инциденты и разрушения
- **🛸 Буксиры-помощники** - помогают с поврежденными контейнерами
- **🛸 Контроллеры нагрузки** - следят за перегруженными кораблями

## Контроллеры в Kubernetes

**Контроллер** - это процесс, который:
- ✅ **Непрерывно отслеживает** состояние компонентов
- ✅ **Сравнивает** текущее состояние с желаемым
- ✅ **Выполняет действия** для приведения системы в нужное состояние
- ✅ **Работает через** kube-apiserver

---

</details>

<details>
<summary><b>🔧Основные контроллеры</b></summary>

---

## Node Controller

Отвечает за мониторинг состояния рабочих узлов:

```
# Тайминги Node Controller
--node-monitor-period=5s       # Проверка каждые 5 секунд
--node-monitor-grace-period=40s # Ожидание перед отметкой недоступности
--pod-eviction-timeout=5m0s    # Ожидание перед эвакуацией Pod'ов
```

**Процесс работы:**
1. ❌ Нода перестает отправлять heartbeat
2. ⏱️ Через 40 секунд помечается как недоступная
3. ⏱️ Дается 5 минут на восстановление
4. 🚨 Удаляются Pods и переносятся на другие ноды

## Replication Controller

Следит за ReplicaSets и обеспечивает нужное количество Pods:

```
# Если Pod умирает, контроллер создает новый
apiVersion: apps/v1
kind: ReplicaSet
spec:
  replicas: 3  # Контроллер обеспечит 3 работающих Pod'а
```

## Другие важные контроллеры

| Контроллер | Ответственность |
|------------|----------------|
| **Deployment** | Управление обновлениями приложений |
| **Service** | Сетевой доступ и балансировка |
| **Namespace** | Изоляция ресурсов |
| **PersistentVolume** | Управление хранилищем |
| **Job/CronJob** | Выполнение задач |

---

</details>

<details>
<summary><b>🛠️Установка и настройка</b></summary>

---

## Скачивание и установка

```
# Скачать бинарник kube-controller-manager
wget https://github.com/kubernetes/kubernetes/releases/download/v1.28.0/kubernetes-server-linux-amd64.tar.gz

# Распаковать и установить
tar -xzf kubernetes-server-linux-amd64.tar.gz
cd kubernetes/server/bin
cp kube-controller-manager /usr/local/bin/
```

## Ключевые параметры запуска

```
kube-controller-manager \
  --kubeconfig=/etc/kubernetes/controller-manager.conf \
  --bind-address=0.0.0.0 \
  --cluster-cidr=10.244.0.0/16 \
  --service-cluster-ip-range=10.96.0.0/12 \
  --node-monitor-period=5s \
  --node-monitor-grace-period=40s \
  --pod-eviction-timeout=5m0s \
  --controllers=*,bootstrapsigner,tokencleaner
```

## Важные опции конфигурации

| Параметр | Назначение |
|----------|------------|
| `--controllers` | Список включаемых контроллеров |
| `--node-monitor-period` | Период проверки нод |
| `--node-monitor-grace-period` | Ожидание перед отметкой недоступности |
| `--pod-eviction-timeout` | Таймаут эвакуации Pod'ов |
| `--cluster-cidr` | CIDR кластера |
| `--service-cluster-ip-range` | Диапазон IP для сервисов |

---

</details>

<details>
<summary><b>🔍Просмотр конфигурации</b></summary>

---

## Для кластеров kubeadm

```
# kube-controller-manager работает как Pod
kubectl get pods -n kube-system | grep controller-manager

# Посмотреть манифест Pod
cat /etc/kubernetes/manifests/kube-controller-manager.yaml

# Или через kubectl
kubectl get pod kube-controller-manager-node1 -n kube-system -o yaml
```

## Для ручной установки

```
# Посмотреть systemd service
cat /etc/systemd/system/kube-controller-manager.service

# Или посмотреть запущенный процесс
ps aux | grep kube-controller-manager

# Фильтрация по процессу
ps -ef | grep kube-controller-manager | grep -v grep
```

## Расположение файлов конфигурации

```
# kubeadm кластер
/etc/kubernetes/manifests/kube-controller-manager.yaml
/etc/kubernetes/controller-manager.conf

# Ручная установка  
/etc/systemd/system/kube-controller-manager.service
/etc/kubernetes/controller-manager.conf
```

---

</details>

<details>
<summary><b>⚙️Управление контроллерами</b></summary>

---

## Параметр --controllers

```
# Включить все контроллеры (по умолчанию)
--controllers=*

# Включить только определенные контроллеры
--controllers=deployment,replicaset,namespace

# Исключить определенные контроллеры
--controllers=*-node,-bootstrapsigner
```

## Основные группы контроллеров

```
# Общие контроллеры
deployment, replicaset, namespace, serviceaccount

# Контроллеры нод
node, route, service, cloud-node-lifecycle

# Контроллеры заданий
job, cronjob

# Специальные контроллеры
bootstrapsigner, tokencleaner
```

> ⚠️ **Важно:** Если контроллер не работает или отключен, соответствующая функциональность Kubernetes будет нарушена.

---

</details>

<details>
<summary><b>🔧Траблшутинг</b></summary>

---

## Проверка состояния контроллеров

```
# Проверить статус контроллера
kubectl get pods -n kube-system -l component=kube-controller-manager

# Посмотреть логи контроллера
kubectl logs -n kube-system kube-controller-manager-node1

# Проверить события
kubectl get events --sort-by='.lastTimestamp'
```

## Распространенные проблемы

### Контроллер не запускается
```
# Проверить конфигурацию
kubectl describe pod kube-controller-manager-node1 -n kube-system

# Проверить сертификаты
ls -la /etc/kubernetes/pki/
```

### Ноды не обновляют статус
```
# Проверить настройки таймаутов
ps aux | grep kube-controller-manager | grep -o "node-monitor.*"

# Проверить связь с API сервером
kubectl get nodes -w
```

---

</details>

<details>
<summary><b>🎯Ключевые выводы</b></summary>

---

## Роль Controller Manager

1. **📌 Мозг Kubernetes** - реализует интеллектуальное поведение
2. **📌 Поддержание состояния** - приводит систему к желаемому состоянию
3. **📌 Автоматическое восстановление** - самовосстановление при сбоях
4. **📌 Модульность** - отдельные контроллеры для разных задач
5. **📌 Масштабируемость** - можно включать/отключать контроллеры

## Архитектурные принципы

```
Текущее состояние → Контроллер → Желаемое состояние
       ↓                  ↓              ↓
   kube-apiserver   Сравнение и     kube-apiserver
        ↓           коррекция           ↓
      ETCD                          Изменения в
                                   кластере
```

> 🚀 **Дальше:** Рассмотрим kube-scheduler - компонент, отвечающий за распределение Pod'ов по нодам.

---

</details>

---