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

ENV SSL_CONFD /etc/confd/ssl
ENV SSL_UWSGI /etc/uwsgi/ssl

RUN mkdir -p $SSL_CONFD && \
    mkdir -p $SSL_UWSGI && \
    mkdir -p /etc/confd/conf.d && \
    mkdir -p /etc/confd/templates

COPY defaults.ini.toml /etc/confd/conf.d/
COPY defaults.ini.tmpl /etc/confd/templates/

ONBUILD COPY ca.pem $SSL_CONFD/
ONBUILD COPY client.pem $SSL_CONFD/
ONBUILD COPY client-key.pem $SSL_CONFD/
ONBUILD RUN  chmod 0440 $SSL_CONFD/ca.pem && \
	chmod 0440 $SSL_CONFD/client.pem && \
	chmod 0400 $SSL_CONFD/client-key.pem

ONBUILD COPY ca.pem $SSL_UWSGI/
ONBUILD COPY server.pem $SSL_UWSGI/
ONBUILD COPY server-key.pem $SSL_UWSGI/
ONBUILD RUN chown -R uwsgi:uwsgi $SSL_UWSGI/ && \
	chmod 0440 $SSL_UWSGI/ca.pem && \
	chmod 0440 $SSL_UWSGI/server.pem && \
	chmod 0400 $SSL_UWSGI/server-key.pem

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8000 5432
CMD ["uwsgi", "--ini", "/etc/uwsgi/defaults.ini"]
