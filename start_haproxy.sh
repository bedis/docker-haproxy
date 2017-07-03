#!/bin/sh

set -e
set -x

if [ "$DEBUG" == "enabled" ]; then
	set -x
fi

HAP_CONF_DIR="/etc/haproxy"
HAP_DAEMON="/usr/sbin/haproxy"

# create a default SSL certificate
if [ ! -f $HAP_CONF_DIR/certs/server.pem ]; then
  mkdir -p $HAP_CONF_DIR/certs
  cd $HAP_CONF_DIR/certs/
  openssl req -subj '/CN=example.com/O=mycorp./C=FR' -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout server.key -out server.crt
  cat server.crt server.key > server.pem
  rm -f server.crt server.key
fi

if [ ! -d /var/run/haproxy ]; then
  mkdir -p /var/run/haproxy/chroot
fi

COMMONCFG="-f $HAP_CONF_DIR/common.cfg"

# configure DNS
NAMESERVERIP=$(sed -n 's/^nameserver \(.*\)/\1/p' /etc/resolv.conf)
sed -i "s/nameserver dns.docker .*/nameserver dns.docker ${NAMESERVERIP}:53/" ${HAP_CONF_DIR}/common.cfg

# save the reload command
echo "$HAP_DAEMON -sf \$(cat /var/run/haproxy/pid) ${COMMONCFG} -f $HAP_CONF_DIR/haproxy.cfg -- $HAP_CONF_DIR/svc_*.cfg" >/haproxy.reload

# start up HAProxy
$HAP_DAEMON ${COMMONCFG} -f $HAP_CONF_DIR/haproxy.cfg -- $HAP_CONF_DIR/svc_*.cfg

while true
do
  # renew letsencryt certs
  /letsencryptforhaproxy.sh
  # update OCSP
  /letsencryptocspforhaproxy.sh

  sh /haproxy.reload

  sleep 86400
done


