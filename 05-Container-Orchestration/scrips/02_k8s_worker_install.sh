#!/bin/bash

# Логирование в текущую директорию
LOG_FILE="02_k8s-worker-install.log"
exec > >(tee -a "$LOG_FILE") 2>&1

set -e  # Прерывать выполнение при любой ошибке

echo "=== Настройка Kubernetes WORKER узла ==="
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

# 6. Установка CNI плагинов (ОБЯЗАТЕЛЬНО для worker!)
echo "6. Установка CNI плагинов..."
mkdir -p /opt/cni/bin
curl -L https://github.com/containernetworking/plugins/releases/download/v1.4.0/cni-plugins-linux-amd64-v1.4.0.tgz | tar -C /opt/cni/bin -xz
chmod +x /opt/cni/bin/*

echo "Проверка установленных CNI плагинов:"
ls /opt/cni/bin/

echo "=== Установка WORKER завершена! ==="
echo "Завершение: $(date)"
echo ""
echo "=== ДАЛЬНЕЙШИЕ ДЕЙСТВИЯ ==="
echo "1. На MASTER узле выполните:"
echo "   kubeadm token create --print-join-command"
echo ""
echo "2. Скопируйте команду join и выполните её на этом WORKER узле:"
echo "   sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash <hash>"
echo ""
echo "3. Проверьте на MASTER: kubectl get nodes"
