#!/bin/bash

# Скрипт для автоматического обновления CHANGELOG.md
# Определяет новые .md файлы в staged area и добавляет их в CHANGELOG
# Группирует записи по датам коммитов
# Используется в pre-commit hook для автоматического добавления CHANGELOG.md в коммит

CHANGELOG_FILE="CHANGELOG.md"
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT" || exit 1

# Получаем список новых .md файлов из staged area
# Используем -z для null-terminated строк, чтобы правильно обрабатывать пути с пробелами и спецсимволами
NEW_FILES=$(git diff --cached --diff-filter=A --name-only -z 2>/dev/null | tr '\0' '\n' | grep -E '\.md$' || echo "")

# Убираем пустые строки и нормализуем
# Используем простую проверку вместо sed/grep с [[:space:]] для избежания ошибок
if [ -n "$NEW_FILES" ]; then
    # Убираем пустые строки простым способом
    NEW_FILES=$(printf '%s\n' "$NEW_FILES" | awk 'NF > 0' || echo "")
    # Если результат пустой, устанавливаем пустую строку
    [ -z "$NEW_FILES" ] && NEW_FILES=""
else
    NEW_FILES=""
fi

# Если нет новых файлов, выходим
if [ -z "$NEW_FILES" ]; then
    exit 0
fi

# Получаем текущую дату в формате [день-месяц-год] (для pre-commit используем текущую дату, а не дату коммита)
COMMIT_DATE=$(date +%d-%m-%Y)

# Создаем временный файл для записей
TEMP_FILE=$(mktemp)

# Обрабатываем каждый новый файл
if [ -n "$NEW_FILES" ]; then
    # Используем процесс подстановки вместо pipe, чтобы избежать проблем с подпроцессами
    while IFS= read -r file || [ -n "$file" ]; do
        # Пропускаем пустые строки
        [ -z "$file" ] && continue
        
        # Пропускаем сам CHANGELOG.md и скрипты
        if [ "$file" = "CHANGELOG.md" ] || [ "$file" = "scripts/update-changelog.sh" ]; then
            continue
        fi
        
        # Пропускаем файлы, которые не .md
        if [[ ! "$file" =~ \.md$ ]]; then
            continue
        fi
        
        # Добавляем запись для нового файла (только путь)
        echo "- $file" >> "$TEMP_FILE"
    done <<< "$NEW_FILES"
    
    # Добавляем заголовок "Добавлено:"
    if [ -s "$TEMP_FILE" ]; then
        {
            echo "Добавлено:"
            cat "$TEMP_FILE"
        } > "${TEMP_FILE}.tmp" && mv "${TEMP_FILE}.tmp" "$TEMP_FILE"
    fi
fi

# Если есть новые записи, добавляем их в CHANGELOG
if [ -s "$TEMP_FILE" ]; then
    # Создаем CHANGELOG, если его нет
    if [ ! -f "$CHANGELOG_FILE" ]; then
        cat > "$CHANGELOG_FILE" << 'EOF'
# Changelog

Все изменения в проекте документируются в этом файле.

---
EOF
    fi
    
    # Читаем новые записи
    NEW_ENTRIES=$(cat "$TEMP_FILE")
    
    # Проверяем, есть ли раздел с текущей датой
    DATE_SECTION="## [$COMMIT_DATE]"
    
    if grep -q "^$DATE_SECTION" "$CHANGELOG_FILE"; then
        # Если раздел с датой уже существует, добавляем записи в него
        awk -v date_section="$DATE_SECTION" -v new_entries="$NEW_ENTRIES" '
            $0 == date_section { 
                print
                getline
                if ($0 != "") print
                print new_entries
                next
            }
            { print }
        ' "$CHANGELOG_FILE" > "${CHANGELOG_FILE}.tmp" && mv "${CHANGELOG_FILE}.tmp" "$CHANGELOG_FILE"
    else
        # Если раздела с датой нет, создаем его перед "---"
        if grep -q "^---$" "$CHANGELOG_FILE"; then
            # Вставляем перед "---", убирая лишние пустые строки
            awk -v date_section="$DATE_SECTION" -v new_entries="$NEW_ENTRIES" '
                /^---$/ {
                    # Убираем пустую строку перед "---" если она есть
                    if (prev_line == "") {
                        # Уже была пустая строка, не печатаем еще одну
                    } else {
                        print ""
                    }
                    print date_section
                    print ""
                    print new_entries
                    print ""
                    print "---"
                    next
                }
                { 
                    prev_line = $0
                    print 
                }
            ' "$CHANGELOG_FILE" > "${CHANGELOG_FILE}.tmp" && mv "${CHANGELOG_FILE}.tmp" "$CHANGELOG_FILE"
        else
            # Если нет "---", добавляем раздел с датой и "---" в конец
            {
                cat "$CHANGELOG_FILE"
                echo ""
                echo "$DATE_SECTION"
                echo ""
                echo "$NEW_ENTRIES"
                echo ""
                echo "---"
            } > "${CHANGELOG_FILE}.tmp" && mv "${CHANGELOG_FILE}.tmp" "$CHANGELOG_FILE"
        fi
    fi
fi

# Удаляем временный файл
rm -f "$TEMP_FILE"

# Добавляем обновленный CHANGELOG.md в staging area
# Это нужно для pre-commit hook, чтобы CHANGELOG.md попал в коммит
if [ -f "$CHANGELOG_FILE" ]; then
    git add "$CHANGELOG_FILE" 2>/dev/null || true
fi

exit 0
