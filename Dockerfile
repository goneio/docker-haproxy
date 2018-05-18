FROM alpine:3.6
MAINTAINER Matthew Baggett <matthew@gone.io>

RUN apk update && \
    apk --no-cache add \
            tini \
            haproxy \
            py-pip \
            build-base \
            python-dev \
            ca-certificates \
            bash \
            coreutils \
            redis

COPY . /haproxy-src

RUN cp /haproxy-src/reload.sh /reload.sh && \
    cp /haproxy-src/run.sh /run.sh && \
    cp /haproxy-src/cert-loader.sh /cert-loader.sh && \
    chmod +x /reload.sh /cert-loader.sh /run.sh && \
    cd /haproxy-src && \
    pip install -r requirements.txt && \
    pip install . && \
    apk del build-base python-dev && \
    rm -rf "/tmp/*" "/root/.cache" `find / -regex '.*\.py[co]'` && \
    mkdir /certs

ENV RSYSLOG_DESTINATION=127.0.0.1 \
    MODE=http \
    BALANCE=roundrobin \
    MAXCONN=4096 \
    OPTION="redispatch, httplog, dontlognull, forwardfor" \
    TIMEOUT="connect 5000, client 50000, server 50000" \
    STATS_PORT=1936 \
    STATS_AUTH="stats:stats" \
    SSL_BIND_OPTIONS=no-sslv3 \
    SSL_BIND_CIPHERS="ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:AES128-GCM-SHA256:AES128-SHA256:AES128-SHA:AES256-GCM-SHA384:AES256-SHA256:AES256-SHA:DHE-DSS-AES128-SHA:DES-CBC3-SHA" \
    HEALTH_CHECK="check inter 2000 rise 2 fall 3" \
    NBPROC=1 \
    REDIS_HOST=redis \
    REDIS_PORT=6379 \
    REDIS_DATABASE=0 \
    CERT_FOLDER=/certs

EXPOSE 80 443 1936
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/run.sh"]
