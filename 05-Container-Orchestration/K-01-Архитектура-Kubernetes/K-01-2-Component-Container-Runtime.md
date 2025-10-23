[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [📚 K-01-Архитектура-Kubernetes](../../README.md#-k-01-архитектура-kubernetes)

---

# ☸️K-01-2-Component-Container-Runtime
>Контейнерные рантаймы в Kubernetes: эволюция от Docker к Containerd, CRI стандарт и практическое использование.

📗**Материалы:**
- [Kubernetes — Простым Языком на Понятном Примере [YouTube.com]](https://www.youtube.com/watch?v=TwyhnBDOHPw)

---

<details>
<summary><b>🐳Эволюция контейнерных рантаймов</b></summary>

---

### Исторический контекст

#### Docker (2013-2020)
- **Пионер контейнеризации**
- Полный набор инструментов: runtime, build, registry
- Kubernetes изначально работал только с Docker

#### Containerd (2017-настоящее время)
- **Выделенный runtime** из Docker
- Соответствует CRI (Container Runtime Interface)
- Стандарт для современных Kubernetes кластеров

#### CRI-O (2017-настоящее время)
- **Легковесная альтернатива** Containerd
- Специально разработан для Kubernetes
- Используется в Red Hat OpenShift

---

</details>

<details>
<summary><b>🎯Ключевые выводы</b></summary>

---

### Современные стандарты

```text
✅ Containerd - стандарт для production
✅ CRI-O - альтернатива для легковесных кластеров
✅ Docker больше не рекомендуется для Kubernetes
✅ CRI обеспечивает совместимость
```

### Что изучаем дальше

```text
📚 Следующая тема: Master компоненты
🎯 Практика: Понимание Control Plane
🔧 Инструменты: Углубление в архитектуру
```

---

</details>
