# SoftEther VPN server
FROM alpine:latest as prep

LABEL LABEL maintainer="Alejandro Leal ale@bluphy.com" \
    contributors="" \
    softetherversion="Latest_Stable" \
    updatetime="2023-Sep-27"

RUN apk fix && \
    apk --no-cache --update add git git-lfs

RUN git clone https://github.com/SoftEtherVPN/SoftEtherVPN_Stable.git /usr/local/src/SoftEtherVPN_Stable


FROM debian:stable as build

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=prep /usr/local/src /usr/local/src

RUN apt-get update

RUN apt-get install -y --no-install-recommends \
    build-essential \
    wget \
    zip

RUN apt-get install -y --no-install-recommends \
    libncurses6 \
    libreadline8 \
    libncurses-dev \
    libreadline-dev \
    libssl3 \
    libssl-dev \
    zlib1g \
    zlib1g-dev

RUN cd /usr/local/src/SoftEtherVPN_Stable \
    && ./configure \
    && make \
    && make install \
    && touch /usr/vpnserver/vpn_server.config \
    && zip -r9 /artifacts.zip /usr/vpn* /usr/bin/vpn*

FROM debian:stable-slim

COPY --from=build /artifacts.zip /

COPY copyables /

RUN apt-get update

RUN apt-get install -y --no-install-recommends \
    libncurses6 \
    libreadline8 \
    libssl3 \
    iptables \
    unzip \
    zlib1g \
    && unzip -o /artifacts.zip -d / \
    && apt-get autoremove --purge -y  \
    && apt-get clean  -y \
    && rm -rf /var/lib/apt/lists/* \
    && chmod +x /entrypoint.sh /gencert.sh \
    && rm /artifacts.zip \
    && rm -rf /opt \
    && ln -s /usr/vpnserver /opt \
    && find /usr/bin/vpn* -type f ! -name vpnserver \
    -exec bash -c 'ln -s {} /opt/$(basename {})' \;

WORKDIR /usr/vpnserver/

VOLUME ["/usr/vpnserver/server_log/", "/usr/vpnserver/packet_log/", "/usr/vpnserver/security_log/"]

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 500/udp 4500/udp 1701/tcp 1194/udp 5555/tcp 5555/udp 443/tcp

CMD ["/usr/bin/vpnserver", "execsvc"]