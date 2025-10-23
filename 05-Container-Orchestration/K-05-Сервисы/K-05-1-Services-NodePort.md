[🏠 Главная](../../README.md) → [☸️ Container-Orchestration](../../README.md#-container-orchestration) → [📚 K-05-Сервисы](../../README.md#-k-05-сервисы)

---

# ☸️K-05-1-Services-NodePort
>Обеспечение внешнего доступа к приложениям в Kubernetes через NodePort сервисы: порты, балансировка нагрузки и сетевые концепции.

---

<details>
<summary><b>🎯Зачем нужны Services?</b></summary>

---

### Проблемы без Services

```text
# Без Service невозможно внешнее подключение

Node: 192.168.1.2        Laptop: 192.168.1.10
┌─────────────────┐      ❌ Не может подключиться
│ Pod: 10.244.0.2 │      к Pod: 10.244.0.2
│   (nginx:80)    │      (разные сети)
└─────────────────┘
```

---

</details>

<details>
<summary><b>🎯Ключевые выводы</b></summary>

---

### NodePort Services

```text
✅ Внешний доступ к приложениям
✅ Стабильные порты на нодах
✅ Балансировка нагрузки между Pod'ами
✅ Простота настройки
```

### Что изучаем дальше

```text
📚 Следующая тема: ClusterIP Services
🎯 Практика: Внутренние сервисы
🔧 Инструменты: Service discovery
```

---

</details>
