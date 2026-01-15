[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [🔨 K-00-Установка-и-настройка](../../README.md#-k-00-установка-и-настройка)

---

# ☸️K-00-0-Setup-Kubernetes
>Установка собственного кластера Kubernetes: настройка master и worker-нод, запуск сетевого плагина и подключение Dashboard для управления через веб-интерфейс.

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

### Проверка статуса кластера

```bash
# Проверка нод
kubectl get nodes

# Проверка подов в kube-system
kubectl get pods -n kube-system

# Проверка статуса кластера
kubectl cluster-info
```

### Настройка kubectl для пользователя

```bash
# Копирование конфигурации
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

---

</details>

### На Worker Node:
3️⃣ Выполняем:

```bash
curl -O https://raw.githubusercontent.com/mistermedved01/enter-to-devops/master/05-Container-Orchestration/scrips/02_k8s_worker_install.sh
sudo chown +x 02_k8s_worker_install.sh
sudo bash 02_k8s_worker_install.sh
```

4️⃣ После выполнения скрипта на Worker Node, выполняем команду join, которую получили на Master Node:

```bash
sudo kubeadm join 192.168.1.100:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:0123456789abcdef...
```

### На Master Node (после подключения Worker):
5️⃣ Устанавливаем сетевой плагин (CNI):

```bash
# Установка Calico
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Или Flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

6️⃣ Устанавливаем Dashboard:

```bash
curl -O https://raw.githubusercontent.com/mistermedved01/enter-to-devops/master/05-Container-Orchestration/scrips/03_k8s_master_dashboard.sh
sudo chown +x 03_k8s_master_dashboard.sh
sudo bash 03_k8s_master_dashboard.sh
```

## Проверка работоспособности кластера

### Основные команды

```bash
# Проверка нод
kubectl get nodes

# Проверка подов
kubectl get pods --all-namespaces

# Проверка сервисов
kubectl get services --all-namespaces

# Информация о кластере
kubectl cluster-info
```

### Доступ к Dashboard

```bash
# Получение токена для входа в Dashboard
kubectl -n kubernetes-dashboard create token admin-user

# Проброс порта для доступа
kubectl proxy --port=8001

# Доступ: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

## Устранение проблем

### Если нода не подключается

```bash
# Проверка статуса на Worker Node
sudo systemctl status kubelet
sudo systemctl status docker

# Перезапуск сервисов
sudo systemctl restart kubelet
sudo systemctl restart docker
```

### Если поды не запускаются

```bash
# Проверка логов
kubectl logs <pod-name> -n <namespace>

# Описание пода
kubectl describe pod <pod-name> -n <namespace>

# Проверка событий
kubectl get events --sort-by=.metadata.creationTimestamp
```