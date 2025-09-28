# 5-0-Установка-Kubernetes

## Порядок установки Kubernetes кластера

**Выполнять в указанном порядке:**

### На Master Node:
1️⃣ Выполняем:

```bash
curl -O https://raw.githubusercontent.com/mistermedved01/enter-to-devops/master/05-Container-Orchestration/scrips/01_k8s_master_install.sh
sudo chown +x 01_k8s_master_install.sh
sudo bash 01_k8s_master_install.sh
```


2️⃣ При успешной установке компонентов k8s и инициализации ноды, как Master Node, мы должны получить строку для последующих подключений Worker Node:

```bash
kubeadm join 192.168.1.100:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:0123456789abcdef...
```

Не теряем эту строку, а если и потеряли, то она доступна в лог-файле, далее переходим к настройке Worker Node.

<details>
<summary><b>🔧Проверки после выполнения 01_k8s_master_install.sh</b></summary>

---

**1. Проверка состояния ноды:**
```bash
kubectl get nodes
```
**Ожидаемый результат:**
```bash
NAME         STATUS   ROLES           AGE   VERSION
master-node  Ready    control-plane   5m    v1.28.2
```

**2. Проверка системных подов:**
```bash
kubectl get pods -n kube-system
```
**Ожидаемый результат:** Все поды в статусе `Running`
```bash
NAME                               READY   STATUS    RESTARTS   AGE
coredns-5dd5756b68-bqjzv           1/1     Running   0          5m
etcd-master-node                   1/1     Running   0          5m
kube-apiserver-master-node         1/1     Running   0          5m
kube-controller-manager-master-node1/1     Running   0          5m
kube-proxy-x8w9f                   1/1     Running   0          5m
kube-scheduler-master-node         1/1     Running   0          5m
```

**3. Проверка сети Flannel:**
```bash
kubectl get pods -n kube-system | grep flannel
```
**Ожидаемый результат:**
```bash
kube-flannel-ds-abcde             1/1     Running   0          3m
```

**4. Проверка информации о кластере:**
```bash
kubectl cluster-info
```

**5. Получение токена для Worker Node:**
```bash
kubeadm token create --print-join-command
```
**Пример вывода:**
```bash
kubeadm join 192.168.1.100:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:0123456789abcdef...
```

**6. Проверка конфигурации kubectl:**
```bash
kubectl config view
kubectl version --short
```

---

### Если есть проблемы:

**Перезапуск kubelet:**
```bash
sudo systemctl restart kubelet
```

**Проверка логов:**
```bash
sudo journalctl -u kubelet -f
kubectl describe node master-node
```

</details>

---

### На Worker Node:
3️⃣ Выполняем 

```bash
curl -O https://raw.githubusercontent.com/mistermedved01/enter-to-devops/master/05-Container-Orchestration/scrips/02_k8s_worker_install.sh
sudo chown +x 02_k8s_worker_install.sh
sudo bash 02_k8s_worker_install.sh
```

4️⃣ Дожидаемся успешной установки компонентов. Подключаем Worker Node к Master Node по токену из пункта 2.

<details>
<summary><b>🔧Проверки после выполнения 02_k8s_worker_install.sh</b></summary>

---

1. **На Master Node получить команду join:**
```bash
kubeadm token create --print-join-command
```

2. **На Worker Node выполнить команду join:**
```bash
sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash <hash>
```

3. **Проверить подключение на Master Node:**
```bash
kubectl get nodes
```

**Ожидаемый результат:**
```bash
NAME         STATUS   ROLES           AGE   VERSION
master-node  Ready    control-plane   10m   v1.28.2
worker-node  Ready    <none>          2m    v1.28.2
```

</details>

---

### На Master Node:
5️⃣ Выполяем 

```bash
curl -O https://raw.githubusercontent.com/mistermedved01/enter-to-devops/master/05-Container-Orchestration/scrips/03_k8s_master_dashboard.sh
sudo chown +x 03_k8s_master_dashboard.sh
sudo bash 03_k8s_master_dashboard.sh
```

6️⃣ Токен для авторизации в дашборде доступен в лог-файле.

---


<details>
<summary><b>⚙️Описание скрипта 01_k8s_master_install.sh - Master Node</b></summary>

---

## Что делает скрипт:

### 1. Подготовка системы
- Загрузка сетевых модулей ядра
- Настройка sysctl параметров
- Настройка автозагрузки модулей

### 2. Установка containerd
- Установка и настройка container runtime
- Включение systemd cgroup driver

### 3. Установка Kubernetes компонентов
- kubeadm, kubelet, kubectl
- Добавление официального репозитория Kubernetes

### 4. Инициализация кластера
- Инициализация Control Plane
- Настройка pod network CIDR

### 5. Настройка сети
- Установка CNI плагинов
- Развертывание Flannel network plugin

### 6. Финальная настройка
- Настройка kubectl для пользователя
- Проверка состояния кластера
- Генерация токена для worker нод

**Результат:** Готовый Master Node с работающим Control Plane

</details>

<details>
<summary><b>⚙️Описание скрипта 02_k8s_worker_install.sh - Worker Node</b></summary>

## Что делает скрипт:

### 1. Базовая подготовка (аналогично Master)
- Загрузка сетевых модулей ядра
- Настройка sysctl параметров
- Настройка автозагрузки модулей

### 2. Установка containerd
- Установка и настройка container runtime
- Включение systemd cgroup driver

### 3. Установка Kubernetes компонентов
- kubelet, kubeadm, kubectl
- Добавление официального репозитория

### 4. Установка CNI плагинов
- Обязательная установка сетевых плагинов
- Подготовка к подключению к кластеру

### 5. Инструкции для подключения
- Скрипт показывает дальнейшие действия
- Необходимо выполнить команду join с Master

**Особенность:** Скрипт только подготавливает систему, подключение выполняется вручную

</details>

<details>
<summary><b>⚙️Описание скрипта 03_k8s_master_dashboard.sh - Dashboard</b></summary>

---

## Что делает скрипт:

### 1. Проверка кластера
- Проверка подключения к Kubernetes API
- Валидация работоспособности кластера

### 2. Установка Dashboard
- Развертывание официального Kubernetes Dashboard v2.7.0
- Установка в namespace kubernetes-dashboard

### 3. Настройка доступа
- Создание Service Account admin-user
- Настройка ClusterRoleBinding с правами cluster-admin
- Создание NodePort сервиса на порту 30001

### 4. Настройка сети
- Создание NodePort сервиса для внешнего доступа
- Порт 30001 → 443 → 8443 (контейнер Dashboard)

### 5. Генерация токена
- Автоматическое создание токена аутентификации
- Отображение токена и URL для доступа

### 6. Альтернативный доступ
- Настройка port-forward для локального доступа
- Альтернативный URL через порт 8443

**Результат:** Полностью настроенный веб-интерфейс управления кластером

</details>