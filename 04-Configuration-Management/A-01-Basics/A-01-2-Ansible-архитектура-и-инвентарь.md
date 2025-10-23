[🏠 Главная](../../README.md) → [⚙️ Configuration-Management](../../README.md#-configuration-management) → [🚀 A-01-Basics](../../README.md#-a-01-basics)

---

# ⚙️A-01-2-Ansible-архитектура-и-инвентарь
> Архитектура Ansible, управление инвентарем, группы, переменные, динамический инвентарь и организация хостов.

---

<details>
<summary><b>🎯 Архитектура Ansible</b></summary>

---

### Компоненты системы

```text
# Полная архитектура Ansible
┌─────────────────────────────────────────────────┐
│               Control Node                       │
│                                                 │
│  ┌─────────────┐  ┌─────────────┐               │
│  │  Inventory  │  │  Playbooks  │               │
│  │   (YAML)    │  │   (YAML)    │               │
│  └─────────────┘  └─────────────┘               │
│           │               │                     │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────┐ │
│  │   Modules   │  │  Plugins    │  │  Config  │ │
│  │  (Python)   │  │ (Various)   │  │ (INI)    │ │
│  └─────────────┘  └─────────────┘  └──────────┘ │
└─────────────────────────────────────────────────┘
           │               │               │
           ▼               ▼               ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│ Managed     │  │ Managed     │  │ Managed     │
│   Node 1    │  │   Node 2    │  │   Node N    │
│             │  │             │  │             │
│ • Python    │  │ • Python    │  │ • Python    │
│ • SSH       │  │ • SSH       │  │ • SSH       │
└─────────────┘  └─────────────┘  └─────────────┘
```

### Процесс выполнения playbook

```text
# Workflow выполнения:
1. 📋 Парсинг Inventory - загрузка хостов и групп
2. 🔍 Сбор Facts - информация о каждом managed node
3. 📝 Выполнение Tasks - последовательное выполнение
4. 🔄 Обработка Handlers - по триггерам notify
5. 📊 Возврат Results - сбор и вывод результатов

# Для каждого хоста:
• SSH подключение
• Копирование модуля Python
• Выполнение модуля
• Удаление временных файлов
• Возврат JSON результата
```

### Модель выполнения

```text
# Push vs Pull модели
┌─────────────────┬─────────────────┐
│   Push Model    │   Pull Model    │
│    (Ansible)    │   (Puppet/Chef) │
├─────────────────┼─────────────────┤
│ Control Node    │ Managed Nodes   │
│ инициирует      │ периодически    │
│ выполнение      │ запрашивают     │
│                 │ конфигурацию    │
│                 │                 │
│ ✅ Мгновенное   │ ✅ Работает     │
│   выполнение    │   без постоянной│
│ ✅ Централизова-│   связи         │
│   ное управление│ ❌ Задержка     │
│ ❌ Требует      │   обновлений    │
│   доступности   │ ❌ Сложнее      │
│   Control Node  │   отладка       │
└─────────────────┴─────────────────┘
```

---

</details>

<details>
<summary><b>📋 Статический инвентарь</b></summary>

---

### Базовый синтаксис INI

```text
# Простой inventory файл (INI формат)
[web_servers]
web1.example.com
web2.example.com

[db_servers] 
db1.example.com
db2.example.com

[production:children]
web_servers
db_servers

[production:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/production_key
```

### YAML формат инвентаря

```yaml
# inventory/hosts.yml
all:
  children:
    web_servers:
      hosts:
        web1:
          ansible_host: 192.168.1.10
          ansible_user: ubuntu
        web2:
          ansible_host: 192.168.1.11
          ansible_user: deploy
      vars:
        web_package: nginx
        web_port: 80
    
    db_servers:
      hosts:
        db1:
          ansible_host: 192.168.1.20
        db2:
          ansible_host: 192.168.1.21
      vars:
        db_package: postgresql
        db_port: 5432
    
    production:
      children:
        web_servers:
        db_servers:
      vars:
        environment: production
        timezone: Europe/Moscow
```

### Группы и переменные

```text
# Иерархия групп
[production:children]
web_servers
db_servers
monitoring_servers

[staging:children]
staging_web
staging_db

# Переменные на разных уровнях:
1. Глобальные (group_vars/all.yml)
2. Группы (group_vars/web_servers.yml)
3. Хосты (host_vars/host1.yml)
4. В inventory файле
```

---

</details>

<details>
<summary><b>🔄 Динамический инвентарь</b></summary>

---

### Концепция динамического инвентаря

```text
# Динамический инвентарь - скрипт, возвращающий JSON
┌─────────────────┐    JSON     ┌─────────────────┐
│   Cloud API     │ ──────────→ │  Ansible        │
│   (AWS, GCP)    │             │  Inventory      │
└─────────────────┘             └─────────────────┘
         │                               │
         ▼                               ▼
┌─────────────────┐             ┌─────────────────┐
│   Database      │             │   File System   │
│   (MySQL)       │             │   (CSV, YAML)   │
└─────────────────┘             └─────────────────┘
```

### AWS EC2 динамический инвентарь

```bash
#!/bin/bash
# aws_ec2.py - скрипт для AWS EC2

# Установка boto3
pip3 install boto3

# Настройка AWS credentials
aws configure

# Запуск динамического инвентаря
ansible-playbook -i aws_ec2.py playbook.yml

# С кэшированием
ansible-playbook -i aws_ec2.py --cache playbook.yml
```

### Создание собственного динамического инвентаря

```python
#!/usr/bin/env python3
# custom_inventory.py

import json
import sys

def get_inventory():
    """Возвращает инвентарь в формате Ansible"""
    inventory = {
        "_meta": {
            "hostvars": {}
        },
        "web_servers": {
            "hosts": ["web1", "web2"],
            "vars": {
                "web_package": "nginx"
            }
        },
        "db_servers": {
            "hosts": ["db1"],
            "vars": {
                "db_package": "postgresql"
            }
        }
    }
    
    # Добавление hostvars
    inventory["_meta"]["hostvars"]["web1"] = {
        "ansible_host": "192.168.1.10",
        "ansible_user": "ubuntu"
    }
    
    return inventory

if __name__ == "__main__":
    print(json.dumps(get_inventory(), indent=2))
```

---

</details>

<details>
<summary><b>📊 Управление переменными</b></summary>

---

### Иерархия переменных

```text
# Приоритет переменных (от высшего к низшему):
1. Command line variables (-e)
2. Playbook variables (vars:)
3. Host variables (host_vars/)
4. Group variables (group_vars/)
5. Inventory variables
6. Facts (gathered automatically)
7. Role defaults

# Структура каталогов:
inventory/
├── hosts
├── group_vars/
│   ├── all.yml
│   ├── web_servers.yml
│   └── db_servers.yml
└── host_vars/
    ├── web1.yml
    └── db1.yml
```

### Переменные в playbook

```yaml
---
- name: Configure web servers
  hosts: web_servers
  vars:
    web_package: nginx
    web_port: 80
    web_user: www-data
  
  tasks:
    - name: Install web server
      package:
        name: "{{ web_package }}"
        state: present
    
    - name: Start web service
      service:
        name: "{{ web_package }}"
        state: started
        enabled: yes
```

### Факты и переменные

```bash
# Просмотр всех фактов хоста
ansible host1 -m setup

# Просмотр конкретных фактов
ansible host1 -m setup -a "filter=ansible_distribution*"

# Использование фактов в playbook
ansible host1 -m debug -a "var=ansible_distribution"
```

---

</details>

<details>
<summary><b>🔧 Организация инвентаря</b></summary>

---

### Многоуровневая структура

```text
# Сложная структура инвентаря
inventory/
├── production/
│   ├── hosts
│   ├── group_vars/
│   └── host_vars/
├── staging/
│   ├── hosts
│   ├── group_vars/
│   └── host_vars/
└── development/
    ├── hosts
    ├── group_vars/
    └── host_vars/

# Использование:
ansible-playbook -i inventory/production/hosts playbook.yml
ansible-playbook -i inventory/staging/hosts playbook.yml
```

### Переменные окружений

```yaml
# group_vars/all.yml
---
# Глобальные переменные
ansible_user: ubuntu
timezone: Europe/Moscow
package_manager: apt

# group_vars/production.yml
---
# Production переменные
environment: production
debug: false
log_level: error

# group_vars/staging.yml
---
# Staging переменные
environment: staging
debug: true
log_level: info
```

### Инвентарь для разных облаков

```text
# Мульти-облачная структура
inventory/
├── aws/
│   ├── aws_ec2.py
│   └── group_vars/
├── gcp/
│   ├── gcp_compute.py
│   └── group_vars/
└── azure/
    ├── azure_rm.py
    └── group_vars/

# Запуск для разных облаков:
ansible-playbook -i inventory/aws/aws_ec2.py playbook.yml
ansible-playbook -i inventory/gcp/gcp_compute.py playbook.yml
```

---

</details>

<details>
<summary><b>🎯 Ключевые выводы</b></summary>

---

### Best Practices инвентаря

```text
✅ Используйте YAML формат для сложных структур
✅ Организуйте переменные по уровням
✅ Применяйте динамический инвентарь для облаков
✅ Документируйте структуру инвентаря
✅ Используйте группы для логической организации
✅ Кэшируйте динамический инвентарь
```

### Что изучаем дальше

```text
📚 Следующая тема: Ad-Hoc команды
🎯 Практика: Быстрые операции без playbook
🔧 Инструменты: Модули для повседневных задач
```

---

</details>
