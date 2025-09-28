#!/bin/bash

# Логирование в текущую директорию
LOG_FILE="03_k8s_master_dashboard.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Установка Kubernetes Dashboard ==="

# Настройка KUBECONFIG для sudo
export KUBECONFIG=/home/admin1/.kube/config

# Проверка подключения к кластеру
echo "1. Проверка подключения к кластеру..."
kubectl cluster-info
if [ $? -ne 0 ]; then
    echo "Ошибка: Не могу подключиться к Kubernetes API"
    echo "Проверьте: kubectl get nodes"
    exit 1
fi

# 1. Установка Dashboard
echo "2. Установка Dashboard..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml --validate=false

# 2. Ожидание запуска Dashboard
echo "3. Ожидание запуска Dashboard (60 секунд)..."
sleep 60

# 3. Создание admin аккаунта
echo "4. Создание административной учетной записи..."
cat > dashboard-admin.yaml << 'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

kubectl apply -f dashboard-admin.yaml --validate=false

# 4. Настройка NodePort для доступа
echo "5. Настройка доступа через NodePort..."
cat > dashboard-nodeport.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: kubernetes-dashboard-nodeport
  namespace: kubernetes-dashboard
spec:
  type: NodePort
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 30001
  selector:
    k8s-app: kubernetes-dashboard
EOF

kubectl apply -f dashboard-nodeport.yaml --validate=false

# 5. Дополнительное ожидание
echo "6. Ожидание полного запуска (30 секунд)..."
sleep 30

# 6. Проверка установки
echo "7. Проверка установки..."
kubectl get pods -n kubernetes-dashboard

# 7. Получение токена
echo "8. Генерация токена для входа..."
TOKEN=$(kubectl -n kubernetes-dashboard create token admin-user 2>/dev/null || kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}') | grep token: | awk '{print $2}')

echo "=== Установка завершена! ==="
echo ""
echo "=== ДАННЫЕ ДЛЯ ДОСТУПА ==="
echo "URL: https://$(hostname -I | awk '{print $1}'):30001"
echo "Токен: $TOKEN"
echo ""
echo "=== АЛЬТЕРНАТИВНЫЙ ДОСТУП ==="
echo "Port-forward: kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8443:443 --address 0.0.0.0"
echo "Тогда URL: https://localhost:8443"
