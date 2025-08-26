## 1-5-Поиск-и-анализ-файлов-и-текста-find-grep-wc-head-tail

📗**Материалы:**

- [Команда find. Поиск файлов [losst.pro]](https://losst.pro/komanda-find-v-linux)

- [Команда grep. Поиск внутри файлов [losst.pro]](https://losst.pro/gerp-poisk-vnutri-fajlov-v-linux)

- [Команда wc. Подсчёт байт/символов/строк/слов в файлах [losst.pro]](https://losst.pro/komanda-wc-v-linux)

- [Команда head. Вывод начальных строк в файлах [losst.pro]](https://losst.pro/komanda-head-linux)

- [Команда tail. Вывод конечных строк в файлах [losst.pro]](https://losst.pro/komanda-tail-linux)

---

### Команда find

Выполняет поиск файлов и папок по заданным критериям и позволяет выполнять действия с результатами поиска. 

**Синтаксис**

`find` `<где искать>` `<опции>` `<действие>`

`<где искать>` - это начальная точка, с которой утилита начинает поиск файлов, включает все подкаталоги в этом каталоге, то есть по умолчанию поиск рекурсивный. Для поиска в конкретном каталоге можно использовать опцию `maxdepth`

`<опции>` - указывает, какие файлы искать.

`<действие>` - указывает, что делать с каждым найденным файлом, соответствующим критериям.

<details>
<summary><b>🔑Частые сценарии поиска с find</b></summary>

`-name / -iname` — поиск по имени (с учётом/без учёта регистра)

```bash
find /var/log -name "*.log"
find . -iname "readme*"
```

`-type` - тип объекта поиска. Возможные варианты: `f` — файл; `d` — каталог; `l` — ссылка; `p` — pipe; `s` — сокет.

```bash
find /etc -type d -name "nginx"
find . -type f -name "*.sh"
```

`-size` — поиск по размеру

```bash
find /home -type f -size +100M     # больше 100 МБ
find /var -type f -size -10k      # меньше 10 КБ
```

`-mtime / -mmin` — поиск по времени изменения

```bash
find /tmp -type f -mtime +7        # старше 7 дней
find . -type f -mmin -30           # изменён за последние 30 минут
```

`-user / -group` — поиск по владельцу или группе

```bash
find /var/www -user nginx
find /srv -group developers
```

`-perm` — поиск по правам доступа

```bash
find / -perm 777 -type f           # небезопасные файлы
find /usr/bin -perm /4000          # setuid-файлы
```

`-maxdepth` — ограничение глубины поиска

```bash
find . -maxdepth 1 -type f
```

`-prune` — исключение каталогов

```bash
find . -path "./venv" -prune -o -name "*.py" -print
```

`-empty` — поиск пустых файлов/директорий

```bash
find . -type f -empty
find . -type d -empty
```

`-delete` — сразу удалить найденное

```bash
find /tmp -type f -empty -delete
```

`-exec … {} \;` — выполнить команду над найденным.

```bash
find . -name "*.log" -exec gzip {} \;
find /etc -name "*.conf" -exec grep "listen" {} \;
```
</details>

<details>
<summary><b>🔑Чистка по расписанию с find</b></summary>

Команду `find` удобно использовать для автоматического удаления устаревших файлов.

Открываем на редактирование задания cron: `crontab -e`

И добавляем:

```bash
0 0 * * * /bin/find /tmp -mtime +14 -exec rm {} \;
```

в данном примере мы удаляем все файлы и папки из каталога `/tmp`, которые старше `14 дней`. Задание запускается `каждый день в 00:00`.
</details>

---


✍️**Задания:**

🔹**Работа с find (поиск файлов):**