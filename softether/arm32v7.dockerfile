# SoftEther VPN server
FROM arm32v7/debian:stable-slim
LABEL maintainer="Alejandro Leal ajleal@protonmail.com"
LABEL softetherversion="Latest_Stable"

ENV VERSION "Latest_Stable"

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /usr/local/vpnserver

RUN apt-get update &&\
        apt-get -y -q install iptables gcc make wget apt-utils git build-essential libreadline-dev libssl-dev libncurses-dev zlib1g-dev && \
        git clone https://github.com/SoftEtherVPN/SoftEtherVPN_Stable.git ./SoftEtherVPN &&\
        cd SoftEtherVPN &&\
        ./configure &&\
        make &&\
        make install &&\
        cd .. && \
        apt -y -q autoremove && \
        apt-get clean && \
        apt-get purge -y -q --auto-remove gcc make wget git build-essential libreadline-dev libssl-dev libncurses-dev zlib1g-dev && \
        rm -rf /var/cache/apt/* /var/lib/apt/lists/* && \
        rm -rf SoftEtherVPN
 
ADD runner.sh /usr/local/vpnserver/runner.sh
RUN chmod 755 /usr/local/vpnserver/runner.sh

EXPOSE 443/tcp 992/tcp 1194/tcp 1194/udp 5555/tcp 500/udp 4500/udp

ENTRYPOINT ["/usr/local/vpnserver/runner.sh"]