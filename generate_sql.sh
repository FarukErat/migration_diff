#!/bin/bash

# File containing the migration plan
PLAN_FILE="migration_plan.txt"

# Folder to save SQL files
OUTPUT_FOLDER="migrations_sql"

# Create the output folder if it doesn't exist
mkdir -p "$OUTPUT_FOLDER"

# Check if the file exists
if [ ! -f "$PLAN_FILE" ]; then
    echo "Migration plan file not found!"
    exit 1
fi

# Read the plan file and extract migration names
grep -E '^[a-zA-Z0-9_]+\.[0-9]+_[a-zA-Z0-9_]+$' "$PLAN_FILE" | while read -r line; do
    # Extract app label and migration name
    app_label=$(echo "$line" | cut -d '.' -f 1)
    migration_name=$(echo "$line" | cut -d '.' -f 2-)

    # Define the output file path
    output_file="${OUTPUT_FOLDER}/${app_label}_${migration_name}.sql"

    # Generate SQL for the migration and save it to the output file
    echo "Generating SQL for migration: ${app_label}.${migration_name}"
    python manage.py sqlmigrate "$app_label" "${migration_name}" | tee "$output_file"
done
