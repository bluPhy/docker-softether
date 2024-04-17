# SoftEther VPN server
FROM alpine:latest as prep

LABEL maintainer="Alejandro Leal ale@bluphy.com"
LABEL contributors=""
LABEL softetherversion="latest_stable"
LABEL updatetime="2024-April-05"

RUN apk update && apk add --no-cache git

RUN git clone https://github.com/SoftEtherVPN/SoftEtherVPN_Stable.git /usr/local/src/SoftEtherVPN_Stable

FROM alpine:latest as build

COPY --from=prep /usr/local/src /usr/local/src

RUN apk update && apk add --no-cache \
      binutils \
      build-base \
      readline-dev \
      openssl-dev \
      ncurses-dev \
      git \
      cmake \
      gnu-libiconv \
      zlib-dev

RUN cd /usr/local/src/SoftEtherVPN_Stable \
    && ./configure \
    && make \
    && make install \
    && touch /usr/vpnserver/vpn_server.config \
    && tar -czf /artifacts.tar.gz /usr/vpn* /usr/bin/vpn*

FROM alpine:latest

COPY --from=build /artifacts.tar.gz /

COPY copyables /

RUN apk update && apk add --no-cache \
      ca-certificates \
      iptables \
      readline \
      gnu-libiconv \
      zlib \
    && tar xfz artifacts.tar.gz -C / \
    && chmod +x /entrypoint.sh /gencert.sh \
    && rm artifacts.tar.gz \
    && rm -rf /opt \
    && ln -s /usr/vpnserver /opt \
    && find /usr/bin/vpn* -type f ! -name vpnserver \
    -exec bash -c 'ln -s {} /opt/$(basename {})' \;

WORKDIR /usr/vpnserver/

VOLUME ["/usr/vpnserver/server_log/", "/usr/vpnserver/packet_log/", "/usr/vpnserver/security_log/"]

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 500/udp 4500/udp 1701/tcp 1194/udp 5555/tcp 5555/udp 443/tcp

CMD ["/usr/bin/vpnserver", "execsvc"]
