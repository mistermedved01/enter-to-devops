[🏠 Главная](../../README.md) → [⚙️ Configuration-Management](../../README.md#-configuration-management) → [📝 A-02-Playbooks](../../README.md#-a-02-playbooks)

---

# ⚙️A-02-2-Playbook-основы
> Создание и структура Playbook, YAML синтаксис, задачи, модули, выполнение и отладка Playbook.

---

<details>
<summary><b>🎯 Что такое Playbook</b></summary>

---

### Определение и концепция

+++text
# Playbook - декларативное описание желаемого состояния
┌─────────────────────────────────┐
│          Playbook               │
│        (YAML файл)              │
├─────────────────────────────────┤
│  ✅ Описывает "что", а не "как" │
│  ✅ Идемпотентность             │
│  ✅ Структурированная           │
│     автоматизация               │
│  ✅ Повторяемость               │
│  ✅ Документация                │
└─────────────────────────────────┘
---text

### Playbook vs Ad-Hoc команды

+++text
┌─────────────────┬─────────────────┐
│   Ad-Hoc        │   Playbook      │
├─────────────────┼─────────────────┤
│ Быстрые задачи  │ Сложные задачи  │
│ Одноразовые     │ Повторяющиеся   │
│ Простые         │ Структурированные│
│ Отладка         │ Production      │
│ Эксперименты    │ Документированные│
└─────────────────┴─────────────────┘
---text

### Компоненты Playbook

+++text
📝 Playbook состоит из:
• Plays - секции для групп хостов
• Tasks - отдельные операции
• Modules - единицы работы
• Variables - переменные
• Handlers - обработчики событий
• Templates - шаблоны файлов
---text

---

</details>

<details>
<summary><b>📝 YAML синтаксис</b></summary>

---

### Основы YAML

+++yaml
# Простой YAML файл
---
- name: Install and start nginx
  hosts: web_servers
  become: yes
  
  tasks:
    - name: Install nginx
      package:
        name: nginx
        state: present
    
    - name: Start nginx
      service:
        name: nginx
        state: started
        enabled: yes
---yaml

### Структура Playbook

+++yaml
---
# Playbook начинается с ---
- name: "Описание play"           # Название play
  hosts: "target_hosts"           # Целевые хосты
  become: yes                     # Повышение привилегий
  vars:                          # Переменные
    variable_name: value
  
  tasks:                         # Задачи
    - name: "Описание задачи"
      module_name:
        parameter: value
      
  handlers:                      # Обработчики
    - name: "Описание handler"
      module_name:
        parameter: value
---yaml

### Отступы и форматирование

+++yaml
# Правильные отступы (2 пробела)
- name: Configure web server
  hosts: web_servers
  tasks:
    - name: Install nginx
      package:
        name: nginx
        state: present
    
    - name: Configure nginx
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
      notify: restart nginx
---yaml

---

</details>

<details>
<summary><b>🎯 Создание первого Playbook</b></summary>

---

### Базовый Playbook

+++yaml
# playbooks/install_nginx.yml
---
- name: Install and configure nginx
  hosts: web_servers
  become: yes
  
  tasks:
    - name: Update package cache
      apt:
        update_cache: yes
        cache_valid_time: 3600
    
    - name: Install nginx
      package:
        name: nginx
        state: present
    
    - name: Start nginx service
      service:
        name: nginx
        state: started
        enabled: yes
    
    - name: Create web directory
      file:
        path: /var/www/html
        state: directory
        mode: '0755'
        owner: www-data
        group: www-data
---yaml

### Выполнение Playbook

+++bash
# Запуск playbook
ansible-playbook playbooks/install_nginx.yml

# Запуск с проверкой синтаксиса
ansible-playbook --syntax-check playbooks/install_nginx.yml

# Запуск в режиме проверки
ansible-playbook --check playbooks/install_nginx.yml

# Запуск с verbose выводом
ansible-playbook -v playbooks/install_nginx.yml
---bash

---

</details>

<details>
<summary><b>🔧 Структура задач</b></summary>

---

### Компоненты задачи

+++yaml
- name: "Человекочитаемое описание задачи"
  module_name:                    # Модуль Ansible
    parameter1: value1            # Параметры модуля
    parameter2: value2
  when: condition                  # Условие выполнения
  register: variable_name         # Сохранение результата
  notify: handler_name           # Уведомление handler
  tags:                          # Теги для фильтрации
    - tag1
    - tag2
---yaml

### Популярные модули

+++yaml
# Управление пакетами
- name: Install package
  package:
    name: nginx
    state: present

# Управление сервисами
- name: Start service
  service:
    name: nginx
    state: started
    enabled: yes

# Управление файлами
- name: Create directory
  file:
    path: /var/www
    state: directory
    mode: '0755'

# Копирование файлов
- name: Copy file
  copy:
    src: local_file.txt
    dest: /remote/path/file.txt
    mode: '0644'
---yaml

---

</details>

<details>
<summary><b>📊 Выполнение и отладка</b></summary>

---

### Опции выполнения

+++bash
# Базовое выполнение
ansible-playbook playbook.yml

# Выполнение с проверкой
ansible-playbook --check playbook.yml

# Выполнение с diff
ansible-playbook --check --diff playbook.yml

# Выполнение с verbose
ansible-playbook -v playbook.yml
ansible-playbook -vv playbook.yml
ansible-playbook -vvv playbook.yml
---bash

### Ограничение выполнения

+++bash
# Выполнение на конкретных хостах
ansible-playbook -l web_servers playbook.yml

# Выполнение с тегами
ansible-playbook --tags "install,configure" playbook.yml

# Пропуск тегов
ansible-playbook --skip-tags "debug" playbook.yml

# Начать с определенной задачи
ansible-playbook --start-at-task "Install nginx" playbook.yml
---bash

### Отладка проблем

+++bash
# Проверка синтаксиса
ansible-playbook --syntax-check playbook.yml

# Проверка подключения
ansible-playbook --list-hosts playbook.yml

# Тестирование на одном хосте
ansible-playbook -l web1 playbook.yml

# Выполнение с максимальной детализацией
ansible-playbook -vvvv playbook.yml
---bash

---

</details>

<details>
<summary><b>🎯 Ключевые выводы</b></summary>

---

### Best Practices Playbook

+++text
✅ Всегда используйте --syntax-check
✅ Применяйте --check перед выполнением
✅ Добавляйте описательные имена задач
✅ Используйте теги для организации
✅ Документируйте сложную логику
✅ Тестируйте на staging окружении
---text

### Что изучаем дальше

+++text
📚 Следующая тема: Переменные и факты
🎯 Практика: Динамическая конфигурация
🔧 Инструменты: Шаблоны и условия
---text

---

</details>
