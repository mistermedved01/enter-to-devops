[🏠 Главная](../../README.md) → [🐧 Linux](../../README.md#-linux) → [📊 L-12-Логи-и-мониторинг](../../README.md#-l-12-логи-и-мониторинг)

---

# 📊L-12-3-Troubleshooting

## Теория

### Методология troubleshooting
- Систематический подход
- Сбор информации
- Анализ логов
- Тестирование решений
- Документирование

### Уровни диагностики
- Аппаратный уровень
- Системный уровень
- Сетевой уровень
- Прикладной уровень

## Практика

### Базовые команды диагностики
```bash
# Системная информация
uname -a
hostnamectl
lscpu
free -h
df -h

# Процессы и сервисы
ps aux
systemctl status
systemctl list-units --failed

# Сеть
ip addr show
ip route show
ss -tuln
ping -c 3 8.8.8.8

# Логи
sudo journalctl -b
sudo journalctl -u service-name
tail -f /var/log/syslog
```

### Диагностика проблем
```bash
# Проблемы с загрузкой
sudo journalctl -b
sudo dmesg | grep -i error

# Проблемы с сетью
ip addr show
ip route show
ping -c 3 8.8.8.8
traceroute 8.8.8.8

# Проблемы с диском
df -h
lsblk
sudo fdisk -l
sudo smartctl -a /dev/sda
```

### Создание диагностических скриптов
```bash
#!/bin/bash
# system-diagnostics.sh

echo "=== System Information ==="
uname -a
hostnamectl

echo "=== Memory Usage ==="
free -h

echo "=== Disk Usage ==="
df -h

echo "=== Network Interfaces ==="
ip addr show

echo "=== Failed Services ==="
systemctl list-units --failed

echo "=== Recent Errors ==="
sudo journalctl -p err --since "1 hour ago"
```

---

✍️**Вопросы**

1. Как систематически подходить к диагностике проблем?

2. Какие команды использовать для базовой диагностики?

3. Как анализировать логи для поиска проблем?

4. Как диагностировать проблемы с сетью?

5. Как проверить состояние дисков?

6. Как создать диагностический скрипт?

7. Как документировать процесс troubleshooting?

8. Как предотвратить повторение проблем?

9. Как настроить автоматическую диагностику?

10. Как создать базу знаний по troubleshooting?
