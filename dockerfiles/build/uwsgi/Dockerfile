FROM yuanmodu/uwsgi:onbuild

RUN pip install --no-cache-dir wagtail psycopg2
RUN python ${WEBAPP_ROOT}/webapp/manage.py makemigrations \
    python ${WEBAPP_ROOT}/webapp/manage.py migrate \
    python ${WEBAPP_ROOT}/webapp/manage.py createsuperuser \
        --username admin \
        --noinput \
        --email atila.satilmis@gmail.com \
        --database default
