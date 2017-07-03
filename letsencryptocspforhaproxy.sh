#!/bin/bash

# LICENSE: GNU LESSER GENERAL PUBLIC LICENSE Version 2.1, February 1999

if [ ! -z "$DEBUG" ]; then
  set -x
  DEBUG=
fi

ACMEHOME="/root/.acme.sh/"
HAPROXYCERTSHOME="/etc/haproxy/certs"
ACMEOPTIONS="--standalone --httpport 88"
KEYLENGTHLIST="2048 ec-256"
HAPROXY_SOCKET="/var/run/haproxy/socket"
#TEST="--test"

if [ -z "${DOMLIST}" ]; then
  echo "Don't forget to set DOMLIST environment variable"
  exit 1
fi

for D in $DOMLIST
do
  for K in $KEYLENGTHLIST
  do
    echo "### Processing $D - $K ###"
    case "$K" in
      ec-*)
        KEYEXT="ecc"
        CERTDIR=$ACMEHOME/${D}_ecc
        ;;
      *)
        KEYEXT="rsa"
        CERTDIR=$ACMEHOME/${D}
        ;;
    esac

    if [ ! -d $CERTDIR ]; then
      continue
    fi

    OCSPURL=$(openssl x509 -in $CERTDIR/${D}.cer -noout -ocsp_uri)
    OCSPHOST=$(echo $OCSPURL | awk -F'/' '{ print $3 }')

    openssl ocsp -noverify -issuer $CERTDIR/ca.cer -cert $CERTDIR/${D}.cer -no_nonce \
      -url $OCSPURL -host $OCSPHOST -header "HOST" "$OCSPHOST" \
      -respout $CERTDIR/${D}.ocsp

    cp $CERTDIR/${D}.ocsp $HAPROXYHOME/${D}.pem.${KEYEXT}.ocsp

    OCSP64=$(base64 $HAPROXYHOME/${D}.pem.${KEYEXT}.ocsp | tr -d '\n')
    echo "set ssl ocsp-response $OCSP64" | socat stdio ${HAPROXY_SOCKET}

    echo
  done
done

