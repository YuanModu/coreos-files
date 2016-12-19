FROM nginx

ENV CONFD_VERSION 0.11.0

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    rm -rf /var/lib/apt/lists/* && \
    wget -O /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 && \
    chmod +x /usr/local/bin/confd && \
    apt-get purge -y --auto-remove wget

ENV SSL_CONFD /etc/confd/ssl
ENV SSL_NGINX /etc/nginx/ssl
ENV SH_NGINX /etc/yuan/script

RUN mkdir -p $SSL_CONFD && \
    mkdir -p $SSL_NGINX && \
    mkdir -p /etc/confd/conf.d && \
    mkdir -p /etc/confd/templates

COPY nginx.conf.toml /etc/confd/conf.d/
COPY nginx.conf.tmpl /etc/confd/templates/

ONBUILD COPY ca.pem $SSL_CONFD/
ONBUILD COPY client.pem $SSL_CONFD/
ONBUILD COPY client-key.pem $SSL_CONFD/
ONBUILD RUN  chmod 0440 $SSL_CONFD/ca.pem && \
	chmod 0440 $SSL_CONFD/client.pem && \
	chmod 0400 $SSL_CONFD/client-key.pem

ONBUILD COPY ca.pem $SSL_NGINX/
ONBUILD COPY client.pem $SSL_NGINX/
ONBUILD COPY client-key.pem $SSL_NGINX/
ONBUILD RUN chmod 0440 $SSL_NGINX/ca.pem && \
	chmod 0440 $SSL_NGINX/client.pem && \
	chmod 0400 $SSL_NGINX/client-key.pem

ONBUILD COPY nginx-files.sh $SH_NGINX/

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80 443 8000
CMD ["nginx", "-g", "daemon off;"]
