# SoftEther VPN server
FROM alpine:latest as prep

LABEL maintainer="Alejandro Leal ale@bluphy.com"
LABEL contributors=""
LABEL softetherversion="Latest_Stable"
LABEL updatetime="2024-April-02"

RUN apk fix && apk --no-cache --update add git

RUN git clone https://github.com/SoftEtherVPN/SoftEtherVPN_Stable.git /usr/local/src/SoftEtherVPN_Stable

FROM debian:stable-slim as build

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=prep /usr/local/src /usr/local/src

RUN apt update && apt install -y --no-install-recommends --no-cache \
    build-essential \
    wget \
    zip

RUN apt install -y --no-install-recommends --no-cache \
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

RUN apt remove -y gcc perl make build-essential wget curl \
    && apt autoremove --purge -y  \
    && apt clean  -y \
    && rm -rf /var/lib/apt/lists/*

FROM debian:stable-slim

COPY --from=build /artifacts.zip /

COPY copyables /

RUN apt update && apt dist-upgrade -y

RUN apt install -y --no-install-recommends --no-cache \
    libncurses6 \
    libreadline8 \
    libssl3 \
    iptables \
    unzip \
    zlib1g \
    && unzip -o /artifacts.zip -d / \
    && apt autoremove --purge -y  \
    && apt clean  -y \
    && DEBIAN_FRONTEND=noninteractive dpkg -r apt \
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
