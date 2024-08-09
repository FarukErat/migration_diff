#!/bin/bash

# generate old migrations
python manage.py makemigrations
python manage.py migrate

# update the code
git pull

# generate new migrations
python manage.py makemigrations
python manage.py migrate --plan > migration_plan.txt
python manage.py migrate
