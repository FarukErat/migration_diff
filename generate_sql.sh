#!/bin/bash

SQL_OUTPUT_FILE=migrations.sql
if [ -f "$SQL_OUTPUT_FILE" ]; then
    rm "$SQL_OUTPUT_FILE"
fi

MIGRATION_PLAN=$(mktemp)

python manage.py makemigrations
python manage.py migrate --plan > "$MIGRATION_PLAN"

grep -E "^[a-zA-Z0-9_]+\\.[0-9]+_[a-zA-Z0-9_]+$" "$MIGRATION_PLAN" | while read -r line; do
    app_label=$(echo "$line" | cut -d '.' -f 1)
    migration_name=$(echo "$line" | cut -d '.' -f 2-)

    echo "Generating SQL for migration: ${app_label}.${migration_name}"
    python manage.py sqlmigrate "$app_label" "${migration_name}" | sed "/^BEGIN;/d; /^COMMIT;/d" >> "$SQL_OUTPUT_FILE"
done

rm "$MIGRATION_PLAN"
