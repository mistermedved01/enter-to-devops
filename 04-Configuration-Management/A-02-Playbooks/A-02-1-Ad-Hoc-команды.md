[🏠 Главная](../../README.md) → [⚙️ Configuration-Management](../../README.md#-configuration-management) → [📝 A-02-Playbooks](../../README.md#-a-02-playbooks)

---

# ⚙️A-02-1-Ad-Hoc-команды
> Быстрое выполнение задач через Ad-Hoc команды Ansible, основные модули, управление пакетами, сервисами и файлами.

---

<details>
<summary><b>🎯 Что такое Ad-Hoc команды</b></summary>

---

### Определение и использование

```text
# Ad-Hoc команды - быстрые одноразовые задачи
┌─────────────────────────────────┐
│         Ad-Hoc команды          │
├─────────────────────────────────┤
│  ✅ Быстрое выполнение          │
│  ✅ Не требуют создания файлов  │
│  ✅ Идеальны для разовых задач  │
│  ✅ Отладка и проверка          │
│  ✅ Эксперименты и тестирование │
└─────────────────────────────────┘

# Синтаксис:
ansible [pattern] -m [module] -a "[module arguments]"
```

### Когда использовать Ad-Hoc команды

```text
🔧 Разовые операции:
• Перезапуск сервиса
• Проверка дискового пространства
• Установка одного пакета
• Копирование файла

🐛 Отладка и проверка:
• Проверка подключения
• Сбор информации о системе
• Тестирование модулей
• Валидация переменных

🚀 Быстрые задачи:
• Временные изменения
• Экстренные исправления
• Мониторинг состояния
```

### Сравнение с Playbook

```text
┌─────────────────┬─────────────────┐
│   Ad-Hoc        │   Playbook      │
├─────────────────┼─────────────────┤
│ Быстрые задачи  │ Сложные задачи  │
│ Одноразовые     │ Повторяющиеся   │
│ Простые         │ Структурированные│
│ Отладка         │ Production      │
│ Эксперименты    │ Документированные│
└─────────────────┴─────────────────┘
```

---

</details>

<details>
<summary><b>🔧 Основные модули</b></summary>

---

### Модуль ping

+++bash
# Проверка подключения
ansible all -m ping

# Ping конкретной группы
ansible web_servers -m ping

# Ping с verbose выводом
ansible all -m ping -v

# Ping с указанием пользователя
ansible all -m ping -u ubuntu
---bash

### Модуль command

+++bash
# Выполнение произвольных команд
ansible all -m command -a "uptime"

# Выполнение с shell
ansible all -m shell -a "ps aux | grep nginx"

# Проверка дискового пространства
ansible all -m command -a "df -h"

# Проверка памяти
ansible all -m command -a "free -h"
---bash

### Модуль setup (факты)

+++bash
# Сбор всех фактов
ansible all -m setup

# Фильтрация фактов
ansible all -m setup -a "filter=ansible_distribution*"

# Конкретные факты
ansible all -m setup -a "filter=ansible_memory*"

# Факты в JSON формате
ansible all -m setup | jq '.ansible_facts'
---bash

---

</details>

<details>
<summary><b>📦 Управление пакетами</b></summary>

---

### Модуль package

+++bash
# Установка пакета (автоопределение менеджера)
ansible all -m package -a "name=nginx state=present"

# Удаление пакета
ansible all -m package -a "name=apache2 state=absent"

# Обновление всех пакетов
ansible all -m package -a "name=* state=latest"
---bash

### Специфичные модули пакетов

+++bash
# APT (Ubuntu/Debian)
ansible all -m apt -a "name=nginx state=present update_cache=yes"

# YUM (CentOS/RHEL)
ansible all -m yum -a "name=httpd state=present"

# DNF (Fedora)
ansible all -m dnf -a "name=nginx state=present"

# Homebrew (macOS)
ansible all -m homebrew -a "name=git state=present"
---bash

### Управление репозиториями

+++bash
# Добавление репозитория (Ubuntu)
ansible all -m apt_repository -a "repo='deb http://nginx.org/packages/ubuntu/ focal nginx' state=present"

# Установка ключей репозитория
ansible all -m apt_key -a "url=https://nginx.org/keys/nginx_signing.key state=present"
---bash

---

</details>

<details>
<summary><b>🔧 Управление сервисами</b></summary>

---

### Модуль service

+++bash
# Запуск сервиса
ansible all -m service -a "name=nginx state=started"

# Остановка сервиса
ansible all -m service -a "name=nginx state=stopped"

# Перезапуск сервиса
ansible all -m service -a "name=nginx state=restarted"

# Включение автозапуска
ansible all -m service -a "name=nginx enabled=yes"

# Отключение автозапуска
ansible all -m service -a "name=nginx enabled=no"
---bash

### Проверка статуса сервисов

+++bash
# Статус всех сервисов
ansible all -m command -a "systemctl status nginx"

# Список активных сервисов
ansible all -m command -a "systemctl list-units --type=service --state=active"

# Проверка конкретного сервиса
ansible all -m service -a "name=nginx" --check
---bash

---

</details>

<details>
<summary><b>📁 Управление файлами</b></summary>

---

### Модуль file

+++bash
# Создание директории
ansible all -m file -a "path=/tmp/test state=directory"

# Создание файла
ansible all -m file -a "path=/tmp/test.txt state=touch"

# Изменение прав доступа
ansible all -m file -a "path=/tmp/test.txt mode=644"

# Изменение владельца
ansible all -m file -a "path=/tmp/test.txt owner=ubuntu group=ubuntu"

# Создание символической ссылки
ansible all -m file -a "src=/etc/nginx/nginx.conf dest=/tmp/nginx.conf state=link"
---bash

### Модуль copy

+++bash
# Копирование файла
ansible all -m copy -a "src=/local/file.txt dest=/remote/file.txt"

# Копирование с правами
ansible all -m copy -a "src=/local/file.txt dest=/remote/file.txt mode=644"

# Копирование с владельцем
ansible all -m copy -a "src=/local/file.txt dest=/remote/file.txt owner=ubuntu group=ubuntu"

# Создание файла с содержимым
ansible all -m copy -a "content='Hello World' dest=/tmp/hello.txt"
---bash

### Модуль template

+++bash
# Использование шаблонов (требует Jinja2)
ansible all -m template -a "src=/local/template.j2 dest=/remote/config.conf"

# Шаблон с переменными
ansible all -m template -a "src=nginx.conf.j2 dest=/etc/nginx/nginx.conf" -e "port=8080"
---bash

---

</details>

<details>
<summary><b>👥 Управление пользователями</b></summary>

---

### Модуль user

+++bash
# Создание пользователя
ansible all -m user -a "name=deploy state=present"

# Создание пользователя с домашней директорией
ansible all -m user -a "name=deploy state=present createhome=yes"

# Создание пользователя с группой
ansible all -m user -a "name=deploy state=present groups=www-data"

# Удаление пользователя
ansible all -m user -a "name=deploy state=absent"

# Изменение пароля
ansible all -m user -a "name=deploy password={{ 'mypassword' | password_hash('sha512') }}"
---bash

### Модуль group

+++bash
# Создание группы
ansible all -m group -a "name=developers state=present"

# Создание группы с GID
ansible all -m group -a "name=developers state=present gid=1001"

# Удаление группы
ansible all -m group -a "name=developers state=absent"
---bash

---

</details>

<details>
<summary><b>🌐 Сетевые модули</b></summary>

---

### Модуль uri

+++bash
# HTTP запросы
ansible all -m uri -a "url=http://localhost:8080/health return_content=yes"

# POST запрос
ansible all -m uri -a "url=http://api.example.com/data method=POST body='{\"key\":\"value\"}'"

# Проверка доступности API
ansible all -m uri -a "url=https://api.github.com status_code=200"
---bash

### Модуль get_url

+++bash
# Скачивание файлов
ansible all -m get_url -a "url=https://example.com/file.tar.gz dest=/tmp/file.tar.gz"

# Скачивание с проверкой контрольной суммы
ansible all -m get_url -a "url=https://example.com/file.tar.gz dest=/tmp/file.tar.gz checksum=sha256:abc123"

# Скачивание с заголовками
ansible all -m get_url -a "url=https://api.example.com/data dest=/tmp/data.json headers='Authorization: Bearer token'"
---bash

---

</details>

<details>
<summary><b>🔍 Отладка и мониторинг</b></summary>

---

### Модуль debug

+++bash
# Вывод переменных
ansible all -m debug -a "var=ansible_distribution"

# Вывод сообщения
ansible all -m debug -a "msg='Hello from {{ inventory_hostname }}'"

# Вывод фактов
ansible all -m debug -a "var=ansible_facts"
---bash

### Модуль stat

+++bash
# Проверка существования файла
ansible all -m stat -a "path=/etc/nginx/nginx.conf"

# Проверка директории
ansible all -m stat -a "path=/var/www"

# Получение информации о файле
ansible all -m stat -a "path=/etc/passwd"
---bash

### Модуль wait_for

+++bash
# Ожидание доступности порта
ansible all -m wait_for -a "port=80 host=localhost"

# Ожидание файла
ansible all -m wait_for -a "path=/tmp/ready timeout=30"

# Ожидание с проверкой содержимого
ansible all -m wait_for -a "path=/tmp/ready search_regex=ready"
---bash

---

</details>

<details>
<summary><b>⚙️ Продвинутые опции</b></summary>

---

### Параллельное выполнение

+++bash
# Ограничение количества параллельных процессов
ansible all -m ping --forks=5

# Выполнение на одном хосте за раз
ansible all -m ping --forks=1

# Выполнение с задержкой между хостами
ansible all -m ping --forks=1 --serial=1
---bash

### Фильтрация хостов

+++bash
# Выполнение на конкретном хосте
ansible web1 -m ping

# Выполнение на группе
ansible web_servers -m ping

# Выполнение с паттерном
ansible "web*" -m ping

# Исключение хостов
ansible all:!db_servers -m ping
---bash

### Verbose режим

+++bash
# Разные уровни детализации
ansible all -m ping -v    # -v
ansible all -m ping -vv   # -vv
ansible all -m ping -vvv  # -vvv
ansible all -m ping -vvvv # -vvvv (максимальная детализация)
---bash

### Проверка без выполнения

+++bash
# Режим проверки (dry-run)
ansible all -m package -a "name=nginx state=present" --check

# Режим проверки с diff
ansible all -m copy -a "src=/local/file.txt dest=/remote/file.txt" --check --diff
---bash

---

</details>

<details>
<summary><b>🎯 Ключевые выводы</b></summary>

---

### Best Practices Ad-Hoc команд

```text
✅ Используйте для быстрых разовых задач
✅ Всегда проверяйте с --check перед выполнением
✅ Применяйте --forks для контроля параллельности
✅ Используйте -v для отладки проблем
✅ Документируйте сложные команды
✅ Переходите на playbook для сложных задач
```

### Когда использовать Ad-Hoc vs Playbook

```text
🔧 Ad-Hoc команды:
• Быстрые проверки и отладка
• Разовые операции
• Эксперименты с модулями
• Мониторинг состояния

📝 Playbook:
• Повторяющиеся задачи
• Сложная логика
• Документированные процессы
• Production автоматизация
```

### Что изучаем дальше

```text
📚 Следующая тема: Playbook основы
🎯 Практика: Структурированная автоматизация
🔧 Инструменты: YAML синтаксис и best practices
```

---

</details>
