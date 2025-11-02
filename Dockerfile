# syntax=docker/dockerfile:1

# Build arguments for versioning
ARG ALPINE_VERSION=3.19
ARG SOFTETHER_REPO=https://github.com/SoftEtherVPN/SoftEtherVPN.git
ARG SOFTETHER_BRANCH=master

# ============================================
# Builder stage
# ============================================
FROM alpine:${ALPINE_VERSION} AS builder

# Metadata labels
LABEL maintainer="Alejandro Leal ale@bluphy.com"
LABEL contributors=""
LABEL softetherversion="latest_stable"
LABEL description="SoftEther VPN Server - Multi-platform VPN solution"
LABEL org.opencontainers.image.source="https://github.com/bluPhy/docker-softether"
LABEL org.opencontainers.image.title="SoftEther VPN Server"
LABEL org.opencontainers.image.description="Multi-platform SoftEther VPN Server"
LABEL org.opencontainers.image.vendor="bluPhy"

# Install build dependencies in a single layer
RUN apk add --no-cache \
    binutils \
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

# Clone and build SoftEther
ARG SOFTETHER_REPO
ARG SOFTETHER_BRANCH
RUN git clone --depth 1 --branch ${SOFTETHER_BRANCH} ${SOFTETHER_REPO} SoftEtherVPN

ENV USE_MUSL=YES
ENV CMAKE_FLAGS="-DSE_PIDDIR=/run/softether -DSE_LOGDIR=/var/log/softether -DSE_DBDIR=/var/lib/softether"

RUN cd SoftEtherVPN && \
    git submodule init && \
    git submodule update && \
    ./configure && \
    make -j $(getconf _NPROCESSORS_ONLN) -C build && \
    # Strip binaries to reduce size
    strip build/vpnserver build/vpncmd build/*.so

# ============================================
# Base stage with runtime dependencies
# ============================================
FROM alpine:${ALPINE_VERSION} AS base

# Install runtime dependencies
RUN apk add --no-cache \
    readline \
    openssl \
    libsodium \
    gnu-libiconv \
    iptables \
    ca-certificates \
    tzdata && \
    # Create non-root user for running the service
    addgroup -g 1000 softether && \
    adduser -D -u 1000 -G softether -h /var/lib/softether softether && \
    # Create required directories with proper permissions
    mkdir -p /var/log/softether /var/lib/softether /run/softether && \
    chown -R softether:softether /var/log/softether /var/lib/softether /run/softether

ENV LD_PRELOAD=/usr/lib/preloadable_libiconv.so

WORKDIR /usr/local/bin

# Copy binaries and libraries from builder
COPY --from=builder --chown=root:root \
    /usr/local/src/SoftEtherVPN/build/vpncmd \
    /usr/local/src/SoftEtherVPN/build/hamcore.se2 \
    ./

COPY --from=builder --chown=root:root \
    /usr/local/src/SoftEtherVPN/build/libcedar.so \
    /usr/local/src/SoftEtherVPN/build/libmayaqua.so \
    /usr/local/lib/

# Update library cache
RUN ldconfig /usr/local/lib

# Define volumes
VOLUME ["/var/log/softether", "/var/lib/softether", "/run/softether"]

# ============================================
# VPN Server stage
# ============================================
FROM base AS vpnserver

# Copy vpnserver binary
COPY --from=builder --chown=root:root \
    /usr/local/src/SoftEtherVPN/build/vpnserver \
    /usr/local/bin/

# Expose VPN ports
# 443/tcp - HTTPS
# 992/tcp - Telnet over TLS
# 1194/tcp,udp - OpenVPN
# 5555/tcp - L2TP/IPsec
# 500/udp - IPsec IKE
# 4500/udp - IPsec NAT-T
# 1701/udp - L2TP
EXPOSE 443/tcp 992/tcp 1194/tcp 1194/udp 5555/tcp 500/udp 4500/udp 1701/udp

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD /usr/local/bin/vpncmd localhost /SERVER /CMD:Check || exit 1

# Switch to non-root user
USER softether

# Set the command to run the VPN server
CMD ["/usr/local/bin/vpnserver", "execsvc"]

# Metadata labels with build info (will be overridden by build-args)
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.revision="${VCS_REF}"
LABEL org.opencontainers.image.version="${VERSION}"
