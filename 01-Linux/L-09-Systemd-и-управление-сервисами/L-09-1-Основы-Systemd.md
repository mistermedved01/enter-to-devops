[🏠 Главная](../../README.md) → [🐧 Linux](../../README.md#-linux) → [🎛️ L-09-Systemd-и-управление-сервисами](../../README.md#-l-09-systemd-и-управление-сервисами)

---

# 🎛️L-09-1-Основы-Systemd

## Теория

### Что такое Systemd
- Система инициализации и менеджер сервисов
- Заменяет SysV init, Upstart
- Управление процессами, логированием, сетью
- Параллельная загрузка сервисов

### Основные компоненты
- systemd - основной демон
- systemctl - утилита управления
- journald - система логирования
- logind - управление сессиями

## Практика

### Базовые команды systemctl
```bash
# Управление сервисами
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx
sudo systemctl reload nginx

# Статус сервиса
sudo systemctl status nginx

# Включение/отключение автозапуска
sudo systemctl enable nginx
sudo systemctl disable nginx

# Проверка состояния
sudo systemctl is-active nginx
sudo systemctl is-enabled nginx
```

### Просмотр сервисов
```bash
# Все сервисы
sudo systemctl list-units --type=service

# Только активные сервисы
sudo systemctl list-units --type=service --state=active

# Неудавшиеся сервисы
sudo systemctl --failed

# Все unit файлы
sudo systemctl list-unit-files
```

### Управление целями (targets)
```bash
# Просмотр текущей цели
sudo systemctl get-default

# Установка цели по умолчанию
sudo systemctl set-default multi-user.target

# Переключение на цель
sudo systemctl isolate graphical.target
```

---

✍️**Вопросы**

1. Что такое systemd и зачем он нужен?

2. В чём разница между systemd и SysV init?

3. Как управлять сервисами в systemd?

4. Как включить автозапуск сервиса?

5. Как посмотреть статус сервиса?

6. Что такое targets в systemd?

7. Как переключиться между targets?

8. Как посмотреть неудавшиеся сервисы?

9. В чём преимущества systemd перед SysV init?

10. Как настроить systemd для максимальной производительности?
