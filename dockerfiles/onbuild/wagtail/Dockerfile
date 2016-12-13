FROM python

ENV CONFD_VERSION 0.11.0
ENV WEBAPP_ROOT /usr/share/webapp

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    rm -rf /var/lib/apt/lists/* && \
    wget -O /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 && \
    chmod +x /usr/local/bin/confd && \
    apt-get purge -y --auto-remove wget

RUN pip install --no-cache-dir wagtail psycopg2

ENV SSL_CONFD /etc/confd/ssl

RUN mkdir -p $SSL_CONFD && \
    mkdir -p /etc/confd/conf.d && \
    mkdir -p /etc/confd/templates

COPY base.py.toml /etc/confd/conf.d/
COPY base.py.tmpl /etc/confd/templates/

ONBUILD COPY ca.pem $SSL_CONFD
ONBUILD COPY client.pem $SSL_CONFD
ONBUILD COPY client-key.pem $SSL_CONFD
ONBUILD RUN  chmod 0440 $SSL_CONFD/ca.pem && \
	chmod 0440 $SSL_CONFD/client.pem && \
	chmod 0400 $SSL_CONFD/client-key.pem

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["confd"]
