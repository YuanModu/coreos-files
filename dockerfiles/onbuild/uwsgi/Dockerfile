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

ENV SSL_ROOT /etc/ssl/self-signed
ENV SSL_CONFD /etc/confd/ssl
ENV SSL_UWSGI /etc/uwsgi/ssl

RUN mkdir -p $SSL_ROOT && \
    mkdir -p $SSL_UWSGI && \
    mkdir -p $SSL_CONFD && \
    mkdir -p /etc/confd/conf.d && \
    mkdir -p /etc/confd/templates

RUN ln -s $SSL_ROOT/ca.pem $SSL_CONFD/ && \
    ln -s $SSL_ROOT/client.pem $SSL_CONFD/ && \
    ln -s $SSL_ROOT/client-key.pem $SSL_CONFD/ && \
    ln -s $SSL_ROOT/ca.pem $SSL_UWSGI/ && \
    ln -s $SSL_ROOT/server.pem $SSL_UWSGI/ && \
    ln -s $SSL_ROOT/server-key.pem $SSL_UWSGI/

COPY defaults.ini.toml /etc/confd/conf.d/
COPY defaults.ini.tmpl /etc/confd/templates/

ONBUILD COPY ca.pem $SSL_ROOT
ONBUILD COPY client.pem $SSL_ROOT
ONBUILD COPY client-key.pem $SSL_ROOT
ONBUILD COPY server.pem $SSL_ROOT
ONBUILD COPY server-key.pem $SSL_ROOT
ONBUILD RUN chmod 0400 $SSL_ROOT/client-key.pem
ONBUILD RUN chmod 0400 $SSL_ROOT/server-key.pem

RUN touch ${WEBAPP_ROOT}/touch-reload
VOLUME ${WEBAPP_ROOT}
WORKDIR ${WEBAPP_ROOT}

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8000 5432
CMD ["uwsgi", "--ini", "/etc/uwsgi/defaults.ini"]
