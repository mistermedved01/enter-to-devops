[🏠 Главная](../../README.md) → [⚙️ Configuration-Management](../../README.md#-configuration-management) → [🚀 A-05-Advanced](../../README.md#-a-05-advanced)

---

# ⚙️A-05-3-Docker-и-Ansible
> Управление Docker контейнерами через Ansible: установка Docker, управление контейнерами, образы, сети и Docker Compose.

---

<details>
<summary><b>🎯 Интеграция Docker и Ansible</b></summary>

---

### Преимущества совместного использования

+++text
# Ansible + Docker = Мощная автоматизация
┌─────────────────────────────────┐
│        Ansible + Docker         │
├─────────────────────────────────┤
│  ✅ Infrastructure as Code      │
│  ✅ Консистентность окружений   │
│  ✅ Масштабируемость            │
│  ✅ Упрощение развертывания     │
│  ✅ Управление оркестрацией     │
└─────────────────────────────────┘
---text

### Docker модули

+++yaml
---
- name: Docker management
  hosts: all
  tasks:
    - name: Install Docker
      package:
        name: docker.io
        state: present
    
    - name: Start Docker service
      service:
        name: docker
        state: started
        enabled: yes
    
    - name: Pull Docker image
      docker_image:
        name: nginx
        tag: latest
        source: pull
    
    - name: Run Docker container
      docker_container:
        name: web-server
        image: nginx:latest
        ports:
          - "80:80"
        state: started
---yaml

---

</details>

<details>
<summary><b>🎯 Ключевые выводы</b></summary>

---

### Best Practices Docker и Ansible

+++text
✅ Используйте Ansible для управления Docker хостами
✅ Применяйте Docker Compose для сложных приложений
✅ Настройте правильные сети и volumes
✅ Используйте теги для организации контейнеров
✅ Документируйте Docker архитектуру
---text

### Что изучаем дальше

+++text
📚 Следующая тема: Тестирование и best practices
🎯 Практика: Production готовность
🔧 Инструменты: Качество кода
---text

---

</details>
