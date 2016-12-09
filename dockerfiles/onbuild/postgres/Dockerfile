FROM yuanmodu/postgres:ssl

RUN mkdir -p $ETCDSSL && \
	mkdir -p $PGSSL

ONBUILD COPY ca.pem $ETCDSSL
ONBUILD COPY client.pem $ETCDSSL
ONBUILD COPY client-key.pem $ETCDSSL
ONBUILD RUN chmod 0400 $ETCDSSL/client-key.pem

ONBUILD COPY ca.pem $PGSSL
ONBUILD COPY peer.pem $PGSSL
ONBUILD COPY peer-key.pem $PGSSL
ONBUILD RUN chown postgres:postgres $PGSSL/ca.pem && \
	chown postgres:postgres $PGSSL/peer.pem && \
	chown postgres:postgres $PGSSL/peer-key.pem && \
	chmod 0400 $PGSSL/peer-key.pem

EXPOSE 5432
CMD ["postgres"]
