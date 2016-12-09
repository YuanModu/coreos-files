FROM python

ENV CONFD_VERSION 0.11.0
ENV WEBAPP_ROOT /usr/share/webapp

RUN groupadd -r uwsgi --gid=999 && useradd -r -g uwsgi --uid=999 uwsgi

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    rm -rf /var/lib/apt/lists/* && \
    wget -O /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 && \
    chmod +x /usr/local/bin/confd && \
    apt-get purge -y --auto-remove wget

RUN pip install --no-cache-dir uwsgi

RUN mkdir -p /etc/confd/conf.d && \
    mkdir -p /etc/confd/templates && \
    mkdir -p /etc/confd/ssl && \
    mkdir -p /etc/uwsgi/ssl

COPY defaults.ini.toml /etc/confd/conf.d/
COPY defaults.ini.tmpl /etc/confd/templates/

ONBUILD COPY ca.pem /etc/confd/ssl/
ONBUILD COPY client.pem /etc/confd/ssl/
ONBUILD COPY client-key.pem /etc/confd/ssl/
ONBUILD RUN chmod 0400 /etc/confd/ssl/client-key.pem

ONBUILD COPY ca.pem /etc/uwsgi/ssl/
ONBUILD COPY peer.pem /etc/uwsgi/ssl/
ONBUILD COPY peer-key.pem /etc/uwsgi/ssl/
ONBUILD RUN chmod 0400 /etc/uwsgi/ssl/peer-key.pem

RUN mkdir -p ${WEBAPP_ROOT} && chown -R uwsgi:uwsgi ${WEBAPP_ROOT}
WORKDIR ${WEBAPP_ROOT}

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8000 5432
CMD ["uwsgi", "--ini", "/etc/uwsgi/defaults.ini", "--pidfile", "/var/run/uwsgi.pid"]
