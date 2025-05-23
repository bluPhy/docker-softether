FROM alpine AS builder
LABEL maintainer="Alejandro Leal ale@bluphy.com"
LABEL contributors=""
LABEL softetherversion="latest_stable"
LABEL updatetime="2025-May-23"

RUN mkdir /usr/local/src && apk add binutils --no-cache\
        linux-headers \
	build-base \
        readline-dev \
        openssl-dev \
        ncurses-dev \
        git \
        cmake \
        zlib-dev \
        libsodium-dev \
        gnu-libiconv 

ENV LD_PRELOAD=/usr/lib/preloadable_libiconv.so
WORKDIR /usr/local/src
RUN git clone https://github.com/SoftEtherVPN/SoftEtherVPN.git
#RUN git clone -b ${GIT_TAG} https://github.com/SoftEtherVPN/SoftEtherVPN.git
ENV USE_MUSL=YES
ENV CMAKE_FLAGS="-DSE_PIDDIR=/run/softether -DSE_LOGDIR=/var/log/softether -DSE_DBDIR=/var/lib/softether"
RUN cd SoftEtherVPN &&\
	git submodule init &&\
	git submodule update &&\
        ./configure &&\
	make -j $(getconf _NPROCESSORS_ONLN) -C build

FROM alpine AS base
RUN apk add --no-cache readline \
        openssl \
        libsodium \
        gnu-libiconv \
        iptables
ENV LD_PRELOAD=/usr/lib/preloadable_libiconv.so
WORKDIR /usr/local/bin
VOLUME /var/log/softether
VOLUME /var/lib/softether
VOLUME /run/softether
COPY --from=builder /usr/local/src/SoftEtherVPN/build/vpncmd /usr/local/src/SoftEtherVPN/build/hamcore.se2 ./
COPY --from=builder /usr/local/src/SoftEtherVPN/build/libcedar.so /usr/local/src/SoftEtherVPN/build/libmayaqua.so /usr/local/lib/


FROM base AS vpnserver
COPY --from=builder /usr/local/src/SoftEtherVPN/build/vpnserver ./
EXPOSE 443/tcp 992/tcp 1194/tcp 1194/udp 5555/tcp 500/udp 4500/udp
CMD ["/usr/local/bin/vpnserver", "execsvc"]