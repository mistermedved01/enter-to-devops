#!/bin/bash

# Логирование в текущую директорию
LOG_FILE="01_k8s_master_install.log"
exec > >(tee -a "$LOG_FILE") 2>&1

set -e  # Прерывать выполнение при любой ошибке

echo "=== Настройка Kubernetes MASTER узла ==="
echo "Начало: $(date)"

# Проверка на root права
if [ "$EUID" -ne 0 ]; then
    echo "Пожалуйста, запустите скрипт с sudo или как root"
    exit 1
fi

# 1. Загрузка необходимых модулей ядра
echo "1. Загрузка модулей ядра..."
modprobe br_netfilter
modprobe ip_tables
modprobe iptable_filter
modprobe iptable_nat
modprobe overlay

echo "Проверка загруженных модулей:"
lsmod | grep -E 'br_netfilter|ip_tables|iptable_filter|iptable_nat|overlay'

# 2. Настройка постоянной загрузки модулей
echo "2. Настройка автозагрузки модулей..."
cat > /etc/modules-load.d/k8s.conf << EOF
br_netfilter
ip_tables
iptable_filter
iptable_nat
overlay
EOF

# 3. Настройка sysctl параметров
echo "3. Настройка сетевых параметров..."
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.ipv4.conf.all.forwarding = 1
EOF

# Применение sysctl параметров
sysctl --system

echo "Проверка примененных параметров:"
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

# 4. Установка и настройка containerd
echo "4. Установка containerd..."
apt update
apt install -y containerd

echo "Настройка конфигурации containerd..."
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# Включение systemd cgroup driver
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

echo "Запуск containerd..."
systemctl daemon-reload
systemctl enable containerd
systemctl restart containerd

echo "Проверка статуса containerd:"
systemctl status containerd --no-pager

# 5. Установка Kubernetes компонентов
echo "5. Установка Kubernetes..."
apt-get install -y apt-transport-https ca-certificates curl gpg

# Создание директории для ключей
mkdir -p /etc/apt/keyrings

# Добавление GPG ключа
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Добавление репозитория
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list

# Установка компонентов
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

echo "=== Базовая установка завершена! ==="
echo "Проверьте версии установленных компонентов:"
kubeadm version
kubectl version --client

# 6. Установка CNI плагинов (ВАЖНО!)
echo "6. Установка CNI плагинов..."
mkdir -p /opt/cni/bin
curl -L https://github.com/containernetworking/plugins/releases/download/v1.4.0/cni-plugins-linux-amd64-v1.4.0.tgz | tar -C /opt/cni/bin -xz
chmod +x /opt/cni/bin/*

echo "Проверка установленных CNI плагинов:"
ls /opt/cni/bin/

# 7. Инициализация кластера
echo "7. Инициализация Kubernetes кластера..."
kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=all

# 8. Настройка kubectl для обычного пользователя
echo "8. Настройка kubectl..."
mkdir -p /home/$SUDO_USER/.kube
cp -i /etc/kubernetes/admin.conf /home/$SUDO_USER/.kube/config
chown $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.kube/config

# 9. Ожидание запуска системных подов
echo "9. Ожидание запуска системных компонентов (120 секунд)..."
sleep 120

# 10. Установка сетевого плагина Flannel
echo "10. Установка Flannel..."
export KUBECONFIG=/home/$SUDO_USER/.kube/config
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# 11. Ожидание запуска Flannel
echo "11. Ожидание запуска сети (60 секунд)..."
sleep 60

# 12. Проверка состояния кластера
echo "12. Проверка состояния кластера:"
kubectl get nodes
kubectl get pods -n kube-system

# 13. Показать команду для присоединения worker нод
echo "13. Команда для присоединения worker нод:"
kubeadm token create --print-join-command

echo "=== Установка MASTER завершена! ==="
echo "Завершение: $(date)"
