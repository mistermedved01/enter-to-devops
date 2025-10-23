[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [📚 K-04-Ресурсы-Kubernetes](../../README.md#-k-04-ресурсы-kubernetes)

---

# ☸️K-04-4-Controller-Deployments
>Deployment управляет ReplicaSet'ами и Pod'ами, позволяя безопасно обновлять приложение, масштабировать его и при необходимости быстро откатывать изменения.

<details>
<summary><b>🔍Что такое Deployment?</b></summary>

---

<img src="img/k8s_deployments.jpg" alt="" width="700">

Deployment предоставляет **декларативное обновление** для Pod'ов и ReplicaSets. Достаточно описать желаемое состояние, а контроллер развертывания изменит текущее состояние на желаемое.

```text
# Иерархия: Deployment → ReplicaSet → Pods

Deployment (nginx-deployment)
    └── ReplicaSet (nginx-rs-123)
        ├── Pod (nginx-1)
        ├── Pod (nginx-2)
        └── Pod (nginx-3)
```

---

</details>

<details>
<summary><b>🎯Ключевые выводы</b></summary>

---

### Deployments

+++text
✅ Управление ReplicaSet'ами и Pod'ами
✅ Rolling updates и rollbacks
✅ Масштабирование приложений
✅ Декларативное управление состоянием
---text

### Что изучаем дальше

+++text
📚 Следующая тема: Namespaces
🎯 Практика: Организация ресурсов
🔧 Инструменты: Логическое разделение
---text

---

</details>
