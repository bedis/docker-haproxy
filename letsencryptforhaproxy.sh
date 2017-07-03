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
#TEST="--test"

if [ -z "${DOMLIST}" ]; then
  echo "Don't forget to set DOMLIST environment variable"
  exit 1
fi

for D in $DOMLIST
do
  for K in $KEYLENGTHLIST
  do
    case "$K" in
      ec-*)
        ACMEKEY="--keylength ec-256"
        KEYEXT="ecc"
        CERTDIR=$ACMEHOME/${D}_ecc
        ;;
      *)
        ACMEKEY="--keylength 2048"
        KEYEXT="rsa"
        CERTDIR=$ACMEHOME/${D}
        ;;
    esac

    if [ -d $CERTDIR ]; then
      ACMEACTION="--renew"
      if [ "$KEYEXT" = "ecc" ]; then
        ACMEKEY="--ecc"
      fi
    else
      ACMEACTION="--issue"
    fi
    $ACMEHOME/acme.sh $TEST $ACMEOPTIONS $ACMEACTION -d $D $ACMEKEY
    cat $CERTDIR/fullchain.cer $CERTDIR/${D}.key > $HAPROXYCERTSHOME/${D}.pem.${KEYEXT}
    echo
  done
done

