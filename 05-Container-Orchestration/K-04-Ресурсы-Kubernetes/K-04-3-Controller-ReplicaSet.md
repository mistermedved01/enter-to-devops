[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [📚 K-04-Ресурсы-Kubernetes](../../README.md#-k-04-ресурсы-kubernetes)

---

# ☸️K-04-3-Controller-ReplicaSet
>ReplicaSet следит, чтобы нужное количество Pod'ов всегда было в работе. Глава объясняет, как он поддерживает стабильность и зачем обычно используется через Deployment.

<details>
<summary><b>🔍Что такое ReplicaSet?</b></summary>

---

ReplicaSet гарантирует, что **определенное количество экземпляров Pod'ов** будет запущено в кластере Kubernetes в любой момент времени.

```text
# ReplicaSet обеспечивает высокую доступность

Node1:                          Node2:
┌─────────────────┐             ┌─────────────────┐
│   Pod (nginx)   │             │   Pod (nginx)   │
│   Pod (nginx)   │             │   Pod (nginx)   │
└─────────────────┘             └─────────────────┘
```

---

</details>

<details>
<summary><b>🎯Ключевые выводы</b></summary>

---

### ReplicaSet

```text
✅ Обеспечивает нужное количество Pod'ов
✅ Автоматическое восстановление при сбоях
✅ Масштабирование по требованию
✅ Обычно используется через Deployment
```

### Что изучаем дальше

```text
📚 Следующая тема: Deployments
🎯 Практика: Управление развертываниями
🔧 Инструменты: Rolling updates
```

---

</details>
