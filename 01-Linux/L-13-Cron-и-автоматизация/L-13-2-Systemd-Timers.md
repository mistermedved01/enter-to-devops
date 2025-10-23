[🏠 Главная](../../README.md) → [🐧 Linux](../../README.md#-linux) → [⏰ L-13-Cron-и-автоматизация](../../README.md#-l-13-cron-и-автоматизация)

---

# ⏰L-13-2-Systemd-Timers

## Теория

### Что такое systemd timers
- Современная замена cron
- Интеграция с systemd
- Более точное планирование
- Лучшая интеграция с логированием

### Преимущества systemd timers
- Точность до микросекунд
- Интеграция с journald
- Зависимости между задачами
- Автоматический перезапуск

## Практика

### Создание systemd timer
```bash
# Создание service файла
sudo nano /etc/systemd/system/my-task.service
```

```ini
[Unit]
Description=My Task
After=network.target

[Service]
Type=oneshot
User=myuser
ExecStart=/usr/local/bin/my-task.sh
```

```bash
# Создание timer файла
sudo nano /etc/systemd/system/my-task.timer
```

```ini
[Unit]
Description=My Task Timer
Requires=my-task.service

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

### Управление timers
```bash
# Включение и запуск timer
sudo systemctl enable my-task.timer
sudo systemctl start my-task.timer

# Просмотр статуса
sudo systemctl status my-task.timer

# Просмотр всех timers
sudo systemctl list-timers

# Ручной запуск service
sudo systemctl start my-task.service
```

### Типы планирования
```ini
# Ежедневно в 2:00
OnCalendar=daily
OnCalendar=*-*-* 02:00:00

# Каждые 6 часов
OnCalendar=*-*-* 00,06,12,18:00:00

# Только в рабочие дни
OnCalendar=Mon..Fri 09:00:00

# Первое число каждого месяца
OnCalendar=monthly
```

---

✍️**Вопросы**

1. В чём преимущества systemd timers перед cron?

2. Как создать systemd timer?

3. Как настроить ежедневное выполнение задачи?

4. Как настроить выполнение только в рабочие дни?

5. Как посмотреть все активные timers?

6. Как вручную запустить service из timer?

7. Как настроить зависимости между timers?

8. Как настроить точное время выполнения?

9. Как интегрировать timer с логированием?

10. Как мигрировать с cron на systemd timers?
