[🏠 Главная](../../README.md) → [🐧 Linux](../../README.md#-linux) → [🔄 L-05-Процесс-загрузки](../../README.md#-l-05-процесс-загрузки)

---

# 🔄L-05-4-Systemd-и-цели-targets

Система инициализации и менеджер служб (PID 1), заменивший SysV init.

**Сравнение с SysV init:**

| Характеристика | SysV init       | Systemd             |
|----------------|-----------------|---------------------|
| Запуск         | Последовательный| Параллельный        |
| Зависимости    | Простые         | Сложные             |
| Журналирование | Файлы           | Единый journal      |
| Контроль       | Basic           | Cgroups, namespaces |

## Структура Systemd:

**Директории:**

```Shell
/etc/systemd/system/          # Пользовательские unit файлы
/usr/lib/systemd/system/      # Системные unit файлы
```

**Типы unit файлов:**

- `.service` - службы и демоны

- `.target` - группы служб (аналоги runlevels)

- `.timer` - таймеры (замена cron)

- `.mount` - точки монтирования

## Основные команды:

```Shell
# Управление службами
systemctl start|stop|restart|reload service_name
systemctl enable|disable service_name    # Автозапуск
systemctl status service_name

# Просмотр информации
systemctl list-units                    # Активные units
systemctl list-unit-files              # Все unit файлы
systemctl --failed                     # Неудавшиеся службы
```

## Цели (Targets):

**Основные цели:**

```Shell
poweroff.target          # Выключение
reboot.target            # Перезагрузка
rescue.target            # Аварийный режим
multi-user.target        # Многопользовательский режим
graphical.target         # Графический режим
```

**Управление целями:**

```Shell
systemctl get-default                    # Текущая цель по умолчанию
systemctl set-default graphical.target   # Установить цель по умолчанию
systemctl isolate multi-user.target      # Переключиться на цель
```

---

✍️**Вопросы**

1. Что такое systemd и зачем он нужен?

2. В чем разница между systemd и SysV init?

3. Что такое unit файлы в systemd?

4. Как управлять службами в systemd?

5. Что такое цели (targets) в systemd?

6. Как установить цель по умолчанию?

7. Как посмотреть статус службы?

8. Как включить автозапуск службы?

9. Что такое PID 1 и почему это важно?

10. Как диагностировать проблемы с systemd?
