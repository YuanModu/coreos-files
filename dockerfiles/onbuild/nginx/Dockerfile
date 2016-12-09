FROM nginx

ENV CONFD_VERSION 0.11.0

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    rm -rf /var/lib/apt/lists/* && \
    wget -O /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 && \
    chmod +x /usr/local/bin/confd && \
    apt-get purge -y --auto-remove wget

RUN mkdir -p /etc/confd/conf.d && \
    mkdir -p /etc/confd/templates && \
    mkdir -p /etc/confd/ssl && \
    mkdir -p /etc/nginx/ssl

COPY nginx.conf.toml /etc/confd/conf.d/
COPY nginx.conf.tmpl /etc/confd/templates/

ONBUILD COPY ca.pem /etc/confd/ssl/
ONBUILD COPY client.pem /etc/confd/ssl/
ONBUILD COPY client-key.pem /etc/confd/ssl/
ONBUILD RUN chmod 0400 /etc/confd/ssl/client-key.pem

ONBUILD COPY ca.pem /etc/nginx/ssl/
ONBUILD COPY peer.pem /etc/nginx/ssl/
ONBUILD COPY peer-key.pem /etc/nginx/ssl/
ONBUILD RUN chmod 0400 /etc/nginx/ssl/peer-key.pem

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
