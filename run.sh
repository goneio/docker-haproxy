#!/bin/bash

echo "Starting Certloader"
/cert-loader.sh

echo "Starting haproxy"
/usr/bin/dockercloud-haproxy