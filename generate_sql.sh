#!/bin/bash

TEMP_FILE=$(mktemp)
python manage.py makemigrations
python manage.py migrate --plan > "$TEMP_FILE"

OUTPUT_FOLDER="migrations_sql"
mkdir -p "$OUTPUT_FOLDER"

index=1

if [ ! -f "$TEMP_FILE" ]; then
    echo "Migration plan file not found!"
    exit 1
fi

grep -E '^[a-zA-Z0-9_]+\.[0-9]+_[a-zA-Z0-9_]+$' "$TEMP_FILE" | while read -r line; do
    app_label=$(echo "$line" | cut -d '.' -f 1)
    migration_name=$(echo "$line" | cut -d '.' -f 2-)

    output_file="${OUTPUT_FOLDER}/${index}_${app_label}_${migration_name}.sql"

    echo "Generating SQL for migration: ${app_label}.${migration_name}"
    python manage.py sqlmigrate "$app_label" "${migration_name}" | tee "$output_file"

    index=$((index + 1))
done

rm "$TEMP_FILE"
