[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [🎛️ K-02-Master-компоненты](../../README.md#-k-02-master-компоненты)

---

# 🎛️K-02-2-Master-Component-Kube-API-Server
>kube-apiserver - единая точка входа в кластер Kubernetes, обрабатывает все API запросы

---

<details>
<summary><b>🎯Роль kube-apiserver в кластере</b></summary>

---

## Центральное связующее звено

**kube-apiserver** - это основной компонент управления, который:
- ✅ **Единственный компонент**, взаимодействующий напрямую с ETCD
- ✅ **Координирует** все операции в кластере
- ✅ **Аутентифицирует** и **валидирует** все запросы
- ✅ **Обеспечивает** согласованность данных

## Высокая доступность

```
# Не единая точка отказа!
# Можно запускать несколько экземпляров kube-apiserver
kube-apiserver --etcd-servers=https://etcd1:2379,https://etcd2:2379
kube-apiserver --etcd-servers=https://etcd1:2379,https://etcd2:2379
```

---

</details>

<details>
<summary><b>🔄Процесс работы kube-apiserver</b></summary>

---

## Последовательность обработки запроса

### 1. Аутентификация и валидация
```
kubectl get pods → kube-apiserver
                   ↓
           Аутентификация пользователя
                   ↓
           Валидация запроса
```

### 2. Работа с данными
```
           Извлечение данных из ETCD
                   ↓
           Ответ пользователю
```

## Пример создания Pod через прямой API-вызов

### Шаг 1: Создание запроса
```
POST /api/v1/namespaces/default/pods
{
  "metadata": {
    "name": "my-pod"
  },
  "spec": {
    "containers": [{
      "name": "nginx",
      "image": "nginx:latest"
    }]
  }
}
```

### Шаг 2: Запись в ETCD
```
kube-apiserver → ETCD: "Pod создан, нода не назначена"
```

### Шаг 3: Scheduler вмешивается
```
Scheduler видит Pod без ноды
         ↓
Выбирает подходящую ноду
         ↓
kube-apiserver → ETCD: "Pod назначен на node-1"
```

### Шаг 4: Kubelet исполняет
```
kube-apiserver → kubelet: "Запусти Pod на node-1"
         ↓
kubelet → Container Runtime: "Запусти контейнер"
         ↓
kubelet → kube-apiserver: "Pod запущен"
         ↓
kube-apiserver → ETCD: "Pod running"
```

---

</details>

<details>
<summary><b>🛠️Установка и настройка</b></summary>

---

## Скачивание и установка

```
# Скачать бинарник kube-apiserver
wget https://github.com/kubernetes/kubernetes/releases/download/v1.28.0/kubernetes-server-linux-amd64.tar.gz

# Распаковать и установить
tar -xzf kubernetes-server-linux-amd64.tar.gz
cd kubernetes/server/bin
cp kube-apiserver /usr/local/bin/
```

## Ключевые параметры запуска

```
kube-apiserver \
  --etcd-servers=https://etcd1:2379,https://etcd2:2379 \
  --tls-cert-file=/path/to/cert.crt \
  --tls-private-key-file=/path/to/cert.key \
  --client-ca-file=/path/to/ca.crt \
  --authorization-mode=RBAC \
  --secure-port=6443
```

## Важные опции конфигурации

| Параметр | Назначение |
|----------|------------|
| `--etcd-servers` | Адреса серверов ETCD |
| `--tls-cert-file` | SSL сертификат |
| `--tls-private-key-file` | Приватный ключ |
| `--client-ca-file` | CA для аутентификации клиентов |
| `--authorization-mode` | Режим авторизации (RBAC) |
| `--secure-port` | Порт для HTTPS |

---

</details>

<details>
<summary><b>🔍Просмотр конфигурации в работающем кластере</b></summary>

---

## Для кластеров, созданных через kubeadm

```
# kube-apiserver работает как Pod
kubectl get pods -n kube-system | grep apiserver

# Посмотреть манифест Pod
cat /etc/kubernetes/manifests/kube-apiserver.yaml

# Или через kubectl
kubectl get pod kube-apiserver-node1 -n kube-system -o yaml
```

## Для ручной установки

```
# Посмотреть systemd service
cat /etc/systemd/system/kube-apiserver.service

# Или посмотреть запущенный процесс
ps aux | grep kube-apiserver

# Фильтрация по процессу
ps -ef | grep kube-apiserver | grep -v grep
```

## Расположение файлов конфигурации

```
# kubeadm кластер
/etc/kubernetes/manifests/kube-apiserver.yaml
/etc/kubernetes/pki/               # Сертификаты

# Ручная установка  
/etc/systemd/system/kube-apiserver.service
/etc/kubernetes/apiserver.conf     # Конфигурационный файл
```

---

</details>

<details>
<summary><b>🔐Безопасность и сертификаты</b></summary>

---

## Почему так много сертификатов?

**Компоненты Kubernetes изначально не доверяют друг другу:**
- ✅ **Взаимная аутентификация** между компонентами
- ✅ **Шифрование** сетевой коммуникации
- ✅ **Защита** от несанкционированного доступа

## Основные сертификаты

```
--tls-cert-file=/etc/kubernetes/pki/apiserver.crt
--tls-private-key-file=/etc/kubernetes/pki/apiserver.key
--client-ca-file=/etc/kubernetes/pki/ca.crt
--etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
--etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
--etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
```

> 💡 **Примечание:** Подробнее о TLS/SSL и сертификатах будем говорить в разделе безопасности.

---

</details>

<details>
<summary><b>🎯Ключевые выводы</b></summary>

---

## Основные функции kube-apiserver

1. **📌 Единственный интерфейс** к ETCD
2. **📌 Центральный координатор** всех операций
3. **📌 Аутентификация и авторизация** всех запросов
4. **📌 Валидация** конфигураций ресурсов
5. **📌 Масштабируемость** - поддержка нескольких экземпляров

## Архитектурные принципы

```
Все компоненты → kube-apiserver → ETCD
       ↓                ↓           ↓
   kubelet       scheduler    controller
   kube-proxy    etcd         cloud-controller
```

> 🚀 **Дальше:** Рассмотрим другие компоненты control plane - scheduler и controller-manager.

---

</details>

---