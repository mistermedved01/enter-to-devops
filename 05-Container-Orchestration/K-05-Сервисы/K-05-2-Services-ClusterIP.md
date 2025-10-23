[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [📚 K-05-Сервисы](../../README.md#-k-05-сервисы)

---

# ☸️K-05-2-Services-ClusterIP
>Внутренняя коммуникация в Kubernetes: связь между микросервисами через ClusterIP сервисы, сервис-дискавери и балансировка нагрузки.

---

<details>
<summary><b>🎯Зачем нужен ClusterIP?</b></summary>

---

### Проблемы микросервисной архитектуры

<img src="img/k8s_cluster_ip_01.jpg" alt="" width="700">

```text
# Без ClusterIP - хрупкие связи между микросервисами

Frontend Pod: 10.244.0.2
    ↓
Backend Pod: 10.244.0.5  ← IP может измениться при перезапуске!
```

---

</details>

<details>
<summary><b>🎯Ключевые выводы</b></summary>

---

### ClusterIP Services

+++text
✅ Внутренняя коммуникация между Pod'ами
✅ Стабильные IP-адреса для сервисов
✅ Автоматический service discovery
✅ Балансировка нагрузки
---text

### Что изучаем дальше

+++text
📚 Следующая тема: LoadBalancer Services
🎯 Практика: Внешние сервисы
🔧 Инструменты: Облачные провайдеры
---text

---

</details>
