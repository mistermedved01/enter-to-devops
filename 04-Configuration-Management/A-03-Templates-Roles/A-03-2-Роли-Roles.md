[🏠 Главная](../../README.md) → [⚙️ Configuration-Management](../../README.md#-configuration-management) → [📝 A-03-Templates-Roles](../../README.md#-a-03-templates-roles)

---

# ⚙️A-03-2-Роли-Roles
> Организация Ansible кода в роли: структура, переиспользование, зависимости, поиск и создание ролей через Ansible Galaxy.

---

<details>
<summary><b>🎯 Что такое роли в Ansible</b></summary>

---

### Концепция ролей

```text
# Роли - переиспользуемые компоненты автоматизации
┌─────────────────────────────────┐
│             Роль                │
│        (Ansible Role)           │
├─────────────────────────────────┤
│  ✅ Логическая группировка      │
│  ✅ Переиспользование кода      │
│  ✅ Стандартная структура       │
│  ✅ Упрощение сложных проектов  │
│  ✅ Сообщество и обмен          │
└─────────────────────────────────┘

# Преимущества ролей:
• Организация кода по функциональности
• Легкое переиспользование между проектами
• Стандартизация структуры
• Упрощение сложных playbook
```

### Структура роли

```text
# Стандартная структура роли
roles/
└── nginx/
    ├── defaults/
    │   └── main.yml          # Переменные по умолчанию
    ├── files/                # Статические файлы
    ├── handlers/
    │   └── main.yml          # Обработчики событий
    ├── meta/
    │   └── main.yml          # Метаданные роли
    ├── tasks/
    │   └── main.yml          # Основные задачи
    ├── templates/            # Jinja2 шаблоны
    ├── tests/               # Тесты роли
    └── vars/
        └── main.yml          # Переменные роли
```

---

</details>

<details>
<summary><b>🔧 Создание роли</b></summary>

---

### Создание роли

+++bash
# Создание роли через ansible-galaxy
ansible-galaxy init nginx

# Создание роли вручную
mkdir -p roles/nginx/{defaults,files,handlers,meta,tasks,templates,tests,vars}
---bash

### Основные файлы роли

+++yaml
# roles/nginx/tasks/main.yml
---
- name: Install nginx
  package:
    name: nginx
    state: present

- name: Configure nginx
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify: restart nginx

- name: Start nginx
  service:
    name: nginx
    state: started
    enabled: yes
---yaml

+++yaml
# roles/nginx/defaults/main.yml
---
# Переменные по умолчанию
nginx_port: 80
nginx_user: www-data
document_root: /var/www/html
---yaml

---

</details>

<details>
<summary><b>🎯 Ключевые выводы</b></summary>

---

### Best Practices ролей

```text
✅ Используйте стандартную структуру ролей
✅ Документируйте переменные в defaults
✅ Применяйте теги для организации
✅ Тестируйте роли на разных системах
✅ Используйте Ansible Galaxy для поиска готовых ролей
```

### Что изучаем дальше

```text
📚 Следующая тема: Хендлеры и обработка ошибок
🎯 Практика: Обработка событий и исключений
🔧 Инструменты: Надежность playbook
```

---

</details>
