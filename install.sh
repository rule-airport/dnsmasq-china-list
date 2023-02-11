#!/bin/bash
set -e

WORKDIR="$(mktemp -d)"
SERVERS=(223.6.6. https://dns.alidns.com/dns-query)
# Others: 223.6.6.6 119.28.28.28
# Not using best possible CDN pop: 1.2.4.8 210.2.4.8
# Broken?: 180.76.76.76

CONF_WITH_SERVERS=(accelerated-domains.china google.china apple.china)
CONF_SIMPLE=(bogus-nxdomain.china)

echo "Downloading latest configurations..."
git clone --depth=1 https://gitee.com/felixonmars/dnsmasq-china-list.git "$WORKDIR"
#git clone --depth=1 https://pagure.io/dnsmasq-china-list.git "$WORKDIR"
#git clone --depth=1 https://github.com/felixonmars/dnsmasq-china-list.git "$WORKDIR"
#git clone --depth=1 https://bitbucket.org/felixonmars/dnsmasq-china-list.git "$WORKDIR"
#git clone --depth=1 https://gitlab.com/felixonmars/dnsmasq-china-list.git "$WORKDIR"
#git clone --depth=1 https://e.coding.net/felixonmars/dnsmasq-china-list.git "$WORKDIR"
#git clone --depth=1 https://codehub.devcloud.huaweicloud.com/dnsmasq-china-list00001/dnsmasq-china-list.git "$WORKDIR"
#git clone --depth=1 http://repo.or.cz/dnsmasq-china-list.git "$WORKDIR"

echo "Removing old configurations..."
for _conf in "${CONF_WITH_SERVERS[@]}" "${CONF_SIMPLE[@]}"; do
  rm -f /opt/AdGuardHome/upstreams/"$_conf"*.conf
done

echo "Installing new configurations..."
for _conf in "${CONF_SIMPLE[@]}"; do
  cp "$WORKDIR/$_conf.conf" "/opt/AdGuardHome/upstreams/$_conf.conf"
done

for _server in "${SERVERS[@]}"; do
  for _conf in "${CONF_WITH_SERVERS[@]}"; do
    cp "$WORKDIR/$_conf.conf" "/opt/AdGuardHome/upstreams/$_conf.$_server.conf"
  done

  sed -i "s/server=\/\(.*\)\/\(.*\)/[\/\1\/]$_server/" /opt/AdGuardHome/upstreams/*."$_server".conf
dones

echo "Cleaning up..."
rm -r "$WORKDIR"
