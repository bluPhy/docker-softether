#!/bin/bash
set -e

/usr/bin/vpnserver start 2>&1 >/dev/null

# while-loop to wait until server comes up
# switch cipher
while :; do
    set +e
    /usr/bin/vpncmd localhost /SERVER /CSV /CMD OpenVpnEnable yes /PORTS:1194 2>&1 >/dev/null
    [[ $? -eq 0 ]] && break
    set -e
    sleep 1
done

/usr/bin/vpncmd localhost /SERVER /CSV /CMD ServerCertGet cert
/usr/bin/vpncmd localhost /SERVER /CSV /CMD ServerKeyGet key

CERT=$(cat cert | sed -r 's/\-{5}[^\-]+\-{5}//g;s/[^A-Za-z0-9\+\/\=]//g;' | tr -d '\r\n')
KEY=$(cat key | sed -r 's/\-{5}[^\-]+\-{5}//g;s/[^A-Za-z0-9\+\/\=]//g;' | tr -d '\r\n')

cat <<E
PSK=
USERS=
CERT=${CERT}
KEY=${KEY}

E
