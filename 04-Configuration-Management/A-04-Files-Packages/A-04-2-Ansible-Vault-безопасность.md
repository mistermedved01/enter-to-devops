[🏠 Главная](../../README.md) → [⚙️ Configuration-Management](../../README.md#-configuration-management) → [📁 A-04-Files-Packages](../../README.md#-a-04-files-packages)

---

# ⚙️A-04-2-Ansible-Vault-безопасность
> Защита конфиденциальных данных в Ansible: шифрование переменных, управление секретами, безопасная работа с паролями и ключами.

---

<details>
<summary><b>🎯 Что такое Ansible Vault</b></summary>

---

### Концепция защиты секретов

```text
# Ansible Vault - шифрование конфиденциальных данных
┌─────────────────────────────────┐
│        Ansible Vault            │
├─────────────────────────────────┤
│  ✅ Шифрование переменных       │
│  ✅ Защита паролей и ключей     │
│  ✅ Безопасное хранение секретов│
│  ✅ Интеграция с Git            │
│  ✅ Командная работа            │
└─────────────────────────────────┘

# Что защищаем:
• Пароли баз данных
• API ключи и токены
• SSH приватные ключи
• SSL сертификаты
• Конфиденциальные конфигурации
```

### Базовые команды Vault

+++bash
# Создание зашифрованного файла
ansible-vault create secrets.yml

# Редактирование зашифрованного файла
ansible-vault edit secrets.yml

# Просмотр зашифрованного файла
ansible-vault view secrets.yml

# Расшифровка файла
ansible-vault decrypt secrets.yml

# Шифрование существующего файла
ansible-vault encrypt secrets.yml
---bash

---

</details>

<details>
<summary><b>🔐 Работа с секретами</b></summary>

---

### Создание файла секретов

+++yaml
# secrets.yml (зашифрованный)
---
database_password: "super_secret_password"
api_key: "sk-1234567890abcdef"
ssh_private_key: |
  -----BEGIN PRIVATE KEY-----
  MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC...
  -----END PRIVATE KEY-----
ssl_certificate: |
  -----BEGIN CERTIFICATE-----
  MIIDXTCCAkWgAwIBAgIJAKoK/Ovj8W...
  -----END CERTIFICATE-----
---yaml

### Использование в playbook

+++yaml
---
- name: Deploy application with secrets
  hosts: all
  vars_files:
    - secrets.yml
  
  tasks:
    - name: Configure database
      template:
        src: database.conf.j2
        dest: /etc/app/database.conf
      vars:
        db_password: "{{ database_password }}"
---yaml

---

</details>

<details>
<summary><b>🎯 Ключевые выводы</b></summary>

---

### Best Practices Vault

```text
✅ Используйте Vault для всех секретов
✅ Храните пароль Vault в безопасном месте
✅ Применяйте разные пароли для разных окружений
✅ Регулярно ротируйте пароли
✅ Документируйте процесс работы с секретами
```

### Что изучаем дальше

```text
📚 Следующая тема: Динамический инвентарь
🎯 Практика: Автоматическое обнаружение хостов
🔧 Инструменты: Cloud провайдеры
```

---

</details>
