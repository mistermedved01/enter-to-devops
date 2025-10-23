[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [📚 K-01-Архитектура-Kubernetes](../../README.md#-k-01-архитектура-kubernetes)

---

# ☸️K-01-2-Component-Container-Runtime
>Container Runtime Interface (CRI), Docker, containerd, CRI-O, эволюция контейнерных рантаймов в Kubernetes

---

<details>
<summary><b>🐳Эволюция контейнерных рантаймов</b></summary>

---

## Исторический контекст

### Docker (2013-2020)
- **Пионер контейнеризации**
- Полный набор инструментов: runtime, build, registry
- Kubernetes изначально работал только с Docker

### Проблемы Docker в Kubernetes:
- **Избыточность** - Kubernetes не использует многие функции Docker
- **Сложность** - много слоев абстракции
- **CRI стандарт** - необходимость единого интерфейса

### Containerd (с 2020)
- **Выделенный рантайм** из Docker
- **Соответствует CRI** (Container Runtime Interface)
- **Более легкий и эффективный**
- **Рекомендуемый рантайм** для современных кластеров

---

</details>

<details>
<summary><b>🔧Container Runtime Interface (CRI)</b></summary>

---

## Что такое CRI?

```go
// CRI - стандартный интерфейс для контейнерных рантаймов
type RuntimeService interface {
    CreateContainer(podSandboxID string, config *ContainerConfig) (string, error)
    StartContainer(containerID string) error
    StopContainer(containerID string, timeout int64) error
    // ...
}
```

**Преимущества CRI:**
- ✅ **Единый интерфейс** для разных рантаймов
- ✅ **Простота интеграции** в Kubernetes
- ✅ **Стандартизация** коммуникации

## Поддерживаемые рантаймы:

- **containerd** (рекомендуемый)
- **CRI-O** (специализированный для Kubernetes)  
- **Docker (через dockershim)** - устарел
- **Mirantis Container Runtime** - замена Docker

---

</details>

<details>
<summary><b>⚙️Docker vs Containerd: сравнение</b></summary>

---

### Архитектура Docker
```
Docker Daemon
    ↓
containerd
    ↓
runc
    ↓
Контейнер
---+

### Архитектура Containerd
```
containerd
    ↓
runc  
    ↓
Контейнер
---+

## Ключевые различия

| Аспект | Docker | Containerd |
|--------|--------|------------|
| **Размер** | ~400MB | ~50MB |
| **Зависимости** | Много | Минимум |
| **CRI поддержка** | Через dockershim | Нативная |
| **Производительность** | Хорошая | Лучшая |
| **Сложность** | Высокая | Низкая |

---

</details>

<details>
<summary><b>🛠️Практическое использование</b></summary>

---

## Проверка рантайма в кластере

```bash
# Проверить ноды и используемый рантайм
kubectl get nodes -o wide

# Посмотреть информацию о контейнерном рантайме
kubectl describe node <node-name> | grep Container

# Проверить версию containerd на ноде
containerd --version
```

## Миграция с Docker на Containerd

### 1. Дренирование ноды
```bash
kubectl drain <node-name> --ignore-daemonsets
```

### 2. Настройка containerd
```bash
# Конфигурация containerd
cat /etc/containerd/config.toml

# Перезапуск containerd
systemctl restart containerd
```

### 3. Настройка kubelet
```bash
# В /var/lib/kubelet/kubeadm-flags.env
--container-runtime=remote
--container-runtime-endpoint=unix:///run/containerd/containerd.sock
```

---

</details>

<details>
<summary><b>🔍Диагностика проблем</b></summary>

---

## Распространенные проблемы

### 1. Containerd не запущен
```bash
systemctl status containerd
journalctl -u containerd -f
```

### 2. Проблемы с образами
```bash
# Посмотреть образы в containerd
crictl images

# Удалить проблемный образ
crictl rmi <image-id>
```

### 3. Проверка контейнеров
```bash
# Список запущенных контейнеров
crictl ps

# Логи контейнера
crictl logs <container-id>
```

---

</details>

<details>
<summary><b>🎯Рекомендации для продакшена</b></summary>

---

## Best Practices

### Выбор рантайма:
- ✅ **Containerd** - для новых кластеров
- ✅ **CRI-O** - для security-focused окружений
- ❌ **Docker** - избегать в новых развертываниях

### Настройка containerd:
```bash
# Оптимизация для production
[plugins."io.containerd.grpc.v1.cri"]
  sandbox_image = "registry.k8s.io/pause:3.9"
  
[plugins."io.containerd.grpc.v1.cri".containerd]
  snapshotter = "overlayfs"
  discard_unpacked_layers = true
```

### Мониторинг:
- **Метрики containerd** - для отслеживания производительности
- **Логи runtime** - для диагностики проблем
- **Health checks** - регулярная проверка состояния

---

</details>

<details>
<summary><b>💡Ключевые выводы</b></summary>

---

1. **📌 Containerd** - стандартный рантайм для современных кластеров Kubernetes
2. **📌 CRI** обеспечивает совместимость между разными рантаймами  
3. **📌 Docker deprecated** - мигрируйте на containerd
4. **📌 Производительность** - containerd легче и быстрее
5. **📌 Стандартизация** - единый интерфейс упрощает управление

> 💡 **Совет:** При создании нового кластера сразу используйте containerd - это сэкономит время на миграции в будущем.

</details>

---