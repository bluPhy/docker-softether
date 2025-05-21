# Dockerfile for SoftEther VPN Server
# This Dockerfile builds a SoftEther VPN server image with a focus on security and optimization.

# ---- Prep Stage ----
# This stage downloads the SoftEtherVPN source code.
FROM alpine:3.19 as prep

# Metadata labels
LABEL maintainer="Alejandro Leal ale@bluphy.com"
LABEL contributors=""
LABEL softetherversion="latest_stable" # Intended SoftEther version (actual version pinned in git clone)
LABEL updatetime="2025-May-21"   # Last significant update to this Dockerfile

# Install git to clone the repository, then clone the specific version, and finally remove git.
RUN apk update && \
    apk add --no-cache git && \
    # Clone the specific stable tag of SoftEtherVPN for reproducibility.
    # --depth 1 creates a shallow clone, downloading only the necessary history.
    git clone --depth 1 --branch v4.44-9807-rtm https://github.com/SoftEtherVPN/SoftEtherVPN_Stable.git /usr/local/src/SoftEtherVPN_Stable && \
    # Remove git after cloning to keep the image lean.
    apk del git

# ---- Build Stage ----
# This stage compiles SoftEtherVPN from the downloaded source.
FROM alpine:3.19 as build

# Copy source code from the prep stage
COPY --from=prep /usr/local/src /usr/local/src

# Install build dependencies for SoftEtherVPN.
# These are required to compile the C code.
RUN apk update && \
    apk add --no-cache \
      binutils \
      build-base \
      readline-dev \
      openssl-dev \
      ncurses-dev \
      cmake \
      gnu-libiconv \
      zlib-dev

# Configure and compile SoftEtherVPN.
# Then, manually copy the compiled artifacts to their target locations.
# This avoids running 'make install' which can have side effects or require root.
RUN cd /usr/local/src/SoftEtherVPN_Stable \
    # Prepare the build environment
    && ./configure \
    # Compile the source code
    && make \
    # Create the target directory for SoftEtherVPN files
    && mkdir -p /usr/vpnserver \
    # Copy the main executables and essential files
    && cp vpnserver /usr/vpnserver/vpnserver \
    && cp vpncmd /usr/vpnserver/vpncmd \
    && cp hamcore.se2 /usr/vpnserver/hamcore.se2 \
    # Make the server and command-line tool executable
    && chmod +x /usr/vpnserver/vpnserver /usr/vpnserver/vpncmd \
    # Create symlinks in /usr/bin for compatibility, similar to 'make install'
    && ln -s /usr/vpnserver/vpnserver /usr/bin/vpnserver \
    && ln -s /usr/vpnserver/vpncmd /usr/bin/vpncmd \
    # Create an empty config file, which can be populated via mounted volumes.
    && touch /usr/vpnserver/vpn_server.config

# ---- Final Stage ----
# This stage creates the final runtime image for SoftEtherVPN.
FROM alpine:3.19

# Copy compiled SoftEtherVPN server files from the build stage
COPY --from=build /usr/vpnserver /usr/vpnserver
# Copy symlinks (or the linked files if symlinks aren't preserved as such by COPY)
COPY --from=build /usr/bin/vpnserver /usr/bin/vpnserver
COPY --from=build /usr/bin/vpncmd /usr/bin/vpncmd

# Copy utility scripts (entrypoints, cert generation) into the image
COPY copyables /

# Install runtime dependencies and set up the environment.
RUN apk update && \
    # ca-certificates: For HTTPS connections (e.g., Let's Encrypt)
    # iptables: For network address translation (NAT) and firewall rules, if needed by SoftEther.
    # readline: For interactive command-line tools (like vpncmd).
    # gnu-libiconv: For character set conversion.
    # zlib: For compression.
    # su-exec: For dropping privileges from root to a non-root user.
    apk add --no-cache \
      ca-certificates \
      iptables \
      readline \
      gnu-libiconv \
      zlib \
      su-exec && \
    # Create a dedicated group and user for running SoftEtherVPN for security.
    addgroup -S vpnusergroup && \
    adduser -S -G vpnusergroup -h /home/vpnuser -s /sbin/nologin vpnuser && \
    # Create log directories. These are typically mounted as volumes.
    mkdir -p /usr/vpnserver/server_log /usr/vpnserver/packet_log /usr/vpnserver/security_log && \
    # Set ownership of the vpnserver directory to the vpnuser.
    # This allows the server to write logs and manage its configuration.
    chown -R vpnuser:vpnusergroup /usr/vpnserver && \
    # Make entrypoint scripts and cert generation script executable.
    chmod +x /entrypoint.sh /gencert.sh /root_entrypoint.sh && \
    # Remove /opt if it exists (it might from base image or previous layers).
    rm -rf /opt && \
    # Create a symlink /opt -> /usr/vpnserver for compatibility or convention.
    ln -s /usr/vpnserver /opt

# Set the working directory for subsequent commands.
WORKDIR /usr/vpnserver/

# Define volumes for persistent data (logs and configuration).
# These directories can be mounted from the host or a data volume container.
VOLUME ["/usr/vpnserver/server_log/", "/usr/vpnserver/packet_log/", "/usr/vpnserver/security_log/"]

# Set the entrypoint script. This script runs as root to perform privileged operations,
# then switches to 'vpnuser' to start the VPN server.
ENTRYPOINT ["/root_entrypoint.sh"]

# Expose standard SoftEtherVPN ports.
# TCP: 443 (HTTPS), 1701 (L2TP/IPsec), 5555 (Management)
# UDP: 500 (IKE), 4500 (IPsec NAT Traversal), 1194 (OpenVPN), 5555 (Management)
EXPOSE 500/udp 4500/udp 1701/tcp 1194/udp 5555/tcp 5555/udp 443/tcp

# Default command to run when the container starts.
# 'execsvc' runs vpnserver as a service (daemonized).
# This is passed as arguments to the ENTRYPOINT script.
CMD ["/usr/bin/vpnserver", "execsvc"]
