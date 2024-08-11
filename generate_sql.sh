#!/bin/bash

SQL_OUTPUT_FILE="migrations.sql"
MIGRATION_PLAN=$(mktemp)
TEMP_OUTPUT=$(mktemp)

python manage.py makemigrations
python manage.py migrate --plan > "$MIGRATION_PLAN"

if [ ! -f "$MIGRATION_PLAN" ]; then
    echo "Migration plan file not found!"
    exit 1
fi

grep -E "^[a-zA-Z0-9_]+\\.[0-9]+_[a-zA-Z0-9_]+$" "$MIGRATION_PLAN" | while read -r line; do
    app_label=$(echo "$line" | cut -d '.' -f 1)
    migration_name=$(echo "$line" | cut -d '.' -f 2-)

    echo "Generating SQL for migration: ${app_label}.${migration_name}"
    python manage.py sqlmigrate "$app_label" "${migration_name}" | sed "/^BEGIN;/d; /^COMMIT;/d" >> "$TEMP_OUTPUT"
done

mv "$TEMP_OUTPUT" "$SQL_OUTPUT_FILE"
rm "$MIGRATION_PLAN"
