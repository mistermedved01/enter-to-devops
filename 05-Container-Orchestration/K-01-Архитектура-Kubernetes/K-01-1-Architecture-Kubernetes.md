[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [📚 K-01-Архитектура-Kubernetes](../../README.md#-k-01-архитектура-kubernetes)

---

# ☸️K-01-1-Architecture-Kubernetes
>master-компоненты, kubelet, API-server, scheduler, etcd, kubectl flow

📗**Материалы:**
- [Kubernetes — Простым Языком на Понятном Примере [YouTube.com]](https://www.youtube.com/watch?v=TwyhnBDOHPw)

---

<details>
<summary><b>🏗️Общая архитектура</b></summary>

---

Архитектура Kubernetes проще, чем кажется - вы **не взаимодействуете напрямую с нодами**. Вся работа осуществляется через:

- **Dashboard** - веб-панель управления
- **API** - программный интерфейс  
- **kubectl** - инструмент командной строки

<img src="../img/k8s_cluster_scheme.png" alt="k8s_cluster_scheme" width="700">

---

## 🎯Control Plane (Master Node) - управляющие узлы

Запускают компоненты управления:

- **kube-apiserver** - API-сервер (единая точка входа)
- **kube-scheduler** - планировщик (распределение Pod'ов по нодам)
- **kube-controller-manager** - менеджер контроллеров (управление состоянием)
- **etcd** - база данных кластера (хранение состояния)

## 🎯Worker Node - рабочие узлы

Запускают приложения:

- **kubelet** - агент Kubernetes на ноде
- **kube-proxy** - сетевой прокси
- **Container Runtime** - Docker/containerd (запуск контейнеров)

---

</details>

<details>
<summary><b>🔄Поток выполнения команд</b></summary>

---

### Как работает kubectl

```bash
kubectl run nginx --image=nginx
```

1. **kubectl** отправляет запрос в **kube-apiserver**
2. **kube-apiserver** сохраняет информацию в **etcd**
3. **kube-scheduler** находит подходящую ноду
4. **kubelet** на ноде запускает контейнер
5. **kube-proxy** настраивает сеть

---

</details>

<details>
<summary><b>🎯Ключевые выводы</b></summary>

---

### Основные принципы

```text
✅ Разделение ответственности между компонентами
✅ API-центричная архитектура
✅ Состояние хранится в etcd
✅ Планировщик распределяет нагрузку
✅ Контроллеры поддерживают желаемое состояние
```

### Что изучаем дальше

```text
📚 Следующая тема: Container Runtime
🎯 Практика: Понимание компонентов
🔧 Инструменты: Углубление в архитектуру
```

---

</details>
