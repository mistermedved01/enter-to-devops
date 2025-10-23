[🏠 Главная](../../README.md) → [⚙️ Configuration-Management](../../README.md#-configuration-management) → [🚀 A-05-Advanced](../../README.md#-a-05-advanced)

---

# ⚙️A-05-2-Модули-для-облаков-AWS-GCP-Azure
> Управление облачными ресурсами через Ansible: создание VM, настройка сетей, управление хранилищами и сервисами в AWS, Azure и GCP.

---

<details>
<summary><b>🎯 Облачные модули Ansible</b></summary>

---

### Поддержка облачных провайдеров

+++text
# Ansible модули для основных облачных платформ
┌─────────────────┬─────────────────┬─────────────────┐
│      AWS        │     Azure       │      GCP        │
├─────────────────┼─────────────────┼─────────────────┤
│  ✅ EC2         │  ✅ Virtual     │  ✅ Compute     │
│  ✅ S3          │     Machines    │     Engine      │
│  ✅ RDS         │  ✅ Storage     │  ✅ Cloud       │
│  ✅ VPC         │  ✅ Networks    │     Storage     │
│  ✅ IAM         │  ✅ Security    │  ✅ IAM         │
└─────────────────┴─────────────────┴─────────────────┘
---text

### AWS модули

+++yaml
---
- name: Create EC2 instance
  hosts: localhost
  tasks:
    - name: Launch EC2 instance
      ec2_instance:
        name: web-server
        image_id: ami-0c02fb55956c7d316
        instance_type: t2.micro
        key_name: my-key
        security_groups: ['web-sg']
        region: us-east-1
      register: ec2_result
---yaml

---

</details>

<details>
<summary><b>🎯 Ключевые выводы</b></summary>

---

### Best Practices облачных модулей

+++text
✅ Используйте теги для организации ресурсов
✅ Применяйте переменные для разных окружений
✅ Настройте правильные security groups
✅ Используйте IAM роли для безопасности
✅ Документируйте облачную архитектуру
---text

### Что изучаем дальше

+++text
📚 Следующая тема: Docker и Ansible
🎯 Практика: Контейнеризация с Ansible
🔧 Инструменты: Docker модули
---text

---

</details>
