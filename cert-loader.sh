#!/bin/bash

echo "Writing default cert to /certs/_default.pem"
echo $DEFAULT_SSL_CERT > /certs/_default.pem

echo "Connecting to Redis...";
CERT_COUNT=0
redis-cli --raw -h $REDIS_HOST -p $REDIS_PORT -n $REDIS_DATABASE KEYS certs:* | while read -r LINE
do
    DOMAIN=`cut -d ":" -f 2 <<< "$LINE"`

    if [ ! -z "$DOMAIN" ]; then
        # printf '%s: %s\n' "$DOMAIN" "$LINE"
        printf ' > Found certificate for %s\n' "$DOMAIN"
        redis-cli --raw -h $REDIS_HOST -p $REDIS_PORT -n $REDIS_DATABASE GET "$LINE" > /certs/$DOMAIN.base64
        cat /certs/$DOMAIN.base64 | base64 -d > /certs/$DOMAIN.pem
        rm /certs/$DOMAIN.base64
        CERT_COUNT=$((CERT_COUNT + 1))
    fi
done

printf '%d certificates imported.\n' $CERT_COUNT

