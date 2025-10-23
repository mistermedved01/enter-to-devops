[🏠 Главная](../../README.md) → [⚙️ Configuration-Management](../../README.md#-configuration-management) → [📝 A-03-Templates-Roles](../../README.md#-a-03-templates-roles)

---

# ⚙️A-03-1-Шаблоны-Template
> Работа с шаблонами Jinja2 в Ansible: динамическая генерация конфигурационных файлов, фильтры, макросы и наследование.

---

<details>
<summary><b>🎯 Что такое шаблоны в Ansible</b></summary>

---

### Концепция шаблонов Jinja2

+++text
# Шаблоны - динамическая генерация файлов
┌─────────────────┐    Шаблон     ┌─────────────────┐
│   Переменные    │ → (Jinja2)  → │ Конфигурационные│
│   Ansible       │               │     файлы       │
└─────────────────┘               └─────────────────┘

Преимущества:
✅ Единый источник истины для конфигураций
✅ Адаптация под разные окружения
✅ Использование переменных и логики
✅ Автоматизация сложных конфигов
---text

### Модуль template

+++yaml
# Базовое использование модуля template
- name: Generate nginx configuration
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    backup: yes
    owner: root
    group: root
    mode: '0644'
  notify: restart nginx
---yaml

### Когда использовать шаблоны

+++text
🔧 Конфигурационные файлы:
• nginx.conf, apache2.conf
• database.cnf, redis.conf
• systemd service files
• environment files

📊 Динамические данные:
• IP адреса и порты
• Пути к директориям
• Пользователи и группы
• Версии приложений
---text

---

</details>

<details>
<summary><b>📝 Базовый синтаксис Jinja2</b></summary>

---

### Переменные в шаблонах

+++text
# templates/nginx.conf.j2
server {
    listen {{ nginx_port | default(80) }};
    server_name {{ server_name }};
    root {{ document_root }};
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    {% if ssl_enabled %}
    listen 443 ssl;
    ssl_certificate {{ ssl_cert_path }};
    ssl_certificate_key {{ ssl_key_path }};
    {% endif %}
}
---text

### Условия и циклы

+++text
# templates/hosts.j2
{% for host in backend_servers %}
{{ host.ip }} {{ host.name }}
{% endfor %}

{% if load_balancer %}
upstream backend {
    {% for server in backend_servers %}
    server {{ server.ip }}:{{ server.port }};
    {% endfor %}
}
{% endif %}
---text

### Фильтры

+++text
# Использование фильтров
{{ database_url | urlparse('hostname') }}
{{ secret_key | hash('sha256') }}
{{ user_list | join(',') }}
{{ config_value | default('default_value') }}
{{ file_content | regex_replace('old', 'new') }}
---text

---

</details>

<details>
<summary><b>🎯 Ключевые выводы</b></summary>

---

### Best Practices шаблонов

+++text
✅ Используйте описательные имена переменных
✅ Применяйте фильтры для форматирования
✅ Документируйте сложную логику
✅ Тестируйте шаблоны на разных данных
✅ Используйте наследование для переиспользования
---text

### Что изучаем дальше

+++text
📚 Следующая тема: Роли Roles
🎯 Практика: Организация переиспользуемого кода
🔧 Инструменты: Структура ролей
---text

---

</details>
