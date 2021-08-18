# SoftEther VPN server

FROM ubuntu:latest
LABEL maintainer="Alejandro Leal ajleal@protonmail.com"
LABEL softetherversion="v4.38-9760-rtm-2021.08.17"

ENV VERSION v4.38-9760-rtm-2021.08.17

WORKDIR /usr/local/vpnserver

RUN apt-get update &&\
        apt-get -y -q install iptables gcc make wget apt-utils && \
        apt-get -y -q upgrade && \
        apt -y -q autoremove && \
        apt-get clean && \
        rm -rf /var/cache/apt/* /var/lib/apt/lists/* && \
        wget http://www.softether-download.com/files/softether/${VERSION}-tree/Linux/SoftEther_VPN_Server/64bit_-_Intel_x64_or_AMD64/softether-vpnserver-${VERSION}-linux-x64-64bit.tar.gz -O /tmp/softether-vpnserver.tar.gz &&\
        tar -xzvf /tmp/softether-vpnserver.tar.gz -C /usr/local/ &&\
        rm /tmp/softether-vpnserver.tar.gz && \
        make i_read_and_agree_the_license_agreement && \
        apt-get purge -y -q --auto-remove gcc make wget

ADD runner.sh /usr/local/vpnserver/runner.sh
RUN chmod 755 /usr/local/vpnserver/runner.sh

EXPOSE 443/tcp 992/tcp 1194/tcp 1194/udp 5555/tcp 500/udp 4500/udp

ENTRYPOINT ["/usr/local/vpnserver/runner.sh"]
