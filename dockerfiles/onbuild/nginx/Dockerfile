FROM nginx

ENV CONFD_VERSION 0.11.0

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    rm -rf /var/lib/apt/lists/* && \
    wget -O /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 && \
    chmod +x /usr/local/bin/confd && \
    apt-get purge -y --auto-remove wget

ENV SSLDIR /usr/share/ssl/certs
ENV NGINXSSL /etc/nginx/ssl
ENV CONFDSSL /etc/confd/ssl

RUN mkdir -p $SSLDIR && \
    mkdir -p $NGINXSSL && \
    mkdir -p $CONFDSSL && \
    mkdir -p /etc/confd/conf.d && \
    mkdir -p /etc/confd/templates

RUN ln -s $SSLDIR/ca.pem $CONFDSSL/ && \
    ln -s $SSLDIR/client.pem $CONFDSSL/ && \
    ln -s $SSLDIR/client-key.pem $CONFDSSL/ && \
    ln -s $SSLDIR/ca.pem $NGINXSSL/ && \
    ln -s $SSLDIR/client.pem $NGINXSSL/ && \
    ln -s $SSLDIR/client-key.pem $NGINXSSL/

COPY nginx.conf.toml /etc/confd/conf.d/
COPY nginx.conf.tmpl /etc/confd/templates/

ONBUILD COPY ca.pem $SSLDIR
ONBUILD COPY client.pem $SSLDIR
ONBUILD COPY client-key.pem $SSLDIR
ONBUILD RUN chmod 0400 $SSLDIR/client-key.pem

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80 443 8000
CMD ["nginx", "-g", "daemon off;"]
