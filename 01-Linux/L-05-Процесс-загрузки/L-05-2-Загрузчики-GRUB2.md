[🏠 Главная](../../README.md) → [🐧 Linux](../../README.md#-linux) → [🔄 L-05-Процесс-загрузки](../../README.md#-l-05-процесс-загрузки)

---

# 🔄L-05-2-Загрузчики-GRUB2

## Что такое GRUB2?

**GRUB2 (GRand Unified Bootloader)** - это современный загрузчик, используемый большинством дистрибутивов Linux для загрузки ядра операционной системы.

---

**Структура файлов GRUB2**

**Основные директории и файлы:**

```Shell
# Основная конфигурация
/boot/grub/grub.cfg                    # Главный конфиг (НЕ РЕДАКТИРОВАТЬ ВРУЧНУЮ!)

# Конфигурационные файлы
/etc/default/grub                       # Основные настройки
/etc/grub.d/                           # Скрипты генерации конфига
    ├── 00_header                      # Базовые настройки
    ├── 10_linux                       # Обнаружение ядер Linux
    ├── 30_os-prober                   # Обнаружение других ОС
    └── 40_custom                      # Пользовательские пункты

# Модули и темы
/boot/grub/
    ├── fonts/                         # Шрифты
    ├── locale/                        # Локализации
    ├── i386-pc/                       # Модули для BIOS
    └── x86_64-efi/                    # Модули для UEFI
```

## Управление конфигурацией GRUB2

**Обновление конфигурации:**

```Shell
# После любых изменений в /etc/default/grub или /etc/grub.d/
sudo update-grub                       # Debian/Ubuntu
sudo grub2-mkconfig -o /boot/grub/grub.cfg  # CentOS/RHEL
sudo grub-mkconfig -o /boot/grub/grub.cfg   # Arch Linux
```

**Просмотр текущей конфигурации:**

```Shell
# Просмотр сгенерированного конфига
cat /boot/grub/grub.cfg

# Просмотр настроек по умолчанию
cat /etc/default/grub
```

## Основные настройки в /etc/default/grub

```Shell
# Время ожидания выбора (секунды)
GRUB_TIMEOUT=10

# Скрыть меню (показывать только при нажатии Shift)
GRUB_TIMEOUT_STYLE=hidden

# Параметры ядра по умолчанию
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"

# Разрешение экрана
GRUB_GFXMODE=1920x1080

# Тема оформления
GRUB_THEME="/boot/grub/themes/ubuntu/theme.txt"
```

## Восстановление GRUB2

**С загрузочного USB:**

```Shell
# Монтирование корневой ФС
sudo mount /dev/sda1 /mnt
sudo mount --bind /dev /mnt/dev
sudo mount --bind /proc /mnt/proc
sudo mount --bind /sys /mnt/sys

# Chroot в систему
sudo chroot /mnt

# Переустановка GRUB2
grub-install /dev/sda
update-grub
```

---

✍️**Вопросы**

1. Что такое GRUB2 и зачем он нужен?

2. В чем разница между GRUB и GRUB2?

3. Как обновить конфигурацию GRUB2?

4. Где хранятся настройки GRUB2?

5. Как восстановить GRUB2 с загрузочного USB?

6. Что такое ESP раздел в UEFI?

7. Как добавить пользовательский пункт в GRUB2?

8. Как изменить время ожидания в GRUB2?

9. Что происходит при нажатии 'e' в меню GRUB2?

10. Как диагностировать проблемы с GRUB2?
