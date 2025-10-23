[🏠 Главная](../../README.md) → [🐧 Linux](../../README.md#-linux) → [🌐 L-11-Сетевые-инструменты](../../README.md#-l-11-сетевые-инструменты)

---

# 🌐L-11-3-Firewall-и-безопасность

## Теория

### Типы файрволов
- iptables - низкоуровневый файрвол
- ufw - упрощенный интерфейс для iptables
- firewalld - динамический файрвол
- nftables - современная замена iptables

### Принципы безопасности
- Минимальные привилегии
- Блокировка по умолчанию
- Логирование подозрительной активности
- Регулярное обновление правил

## Практика

### iptables - базовые команды
```bash
# Просмотр правил
sudo iptables -L -n
sudo iptables -L -n -v

# Очистка правил
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F

# Базовые правила
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# Разрешение loopback
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

# Разрешение установленных соединений
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
```

### ufw - упрощенный файрвол
```bash
# Включение ufw
sudo ufw enable

# Просмотр статуса
sudo ufw status

# Разрешение SSH
sudo ufw allow ssh
sudo ufw allow 22

# Разрешение HTTP/HTTPS
sudo ufw allow 80
sudo ufw allow 443

# Блокировка IP
sudo ufw deny from 192.168.1.100
```

### firewalld - динамический файрвол
```bash
# Проверка статуса
sudo firewall-cmd --state

# Просмотр зон
sudo firewall-cmd --get-zones

# Просмотр активной зоны
sudo firewall-cmd --get-active-zones

# Добавление сервиса
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
```

---

✍️**Вопросы**

1. В чём разница между iptables и ufw?

2. Как настроить базовые правила iptables?

3. Как разрешить SSH подключения?

4. Как заблокировать конкретный IP адрес?

5. Как настроить NAT в iptables?

6. Как использовать firewalld?

7. Как проверить правила файрвола?

8. Как настроить логирование файрвола?

9. Как создать персистентные правила?

10. Как диагностировать проблемы с файрволом?
