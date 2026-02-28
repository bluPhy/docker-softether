# SoftEther VPN Docker Image

Run a SoftEther VPN server in Docker with automatic first-run bootstrap.

[Docker Hub image](https://hub.docker.com/r/ajleal/softether)

![Docker Pulls](https://img.shields.io/docker/pulls/ajleal/softether)
[![Build](https://github.com/bluPhy/docker-softether/actions/workflows/image.yml/badge.svg)](https://github.com/bluPhy/docker-softether/actions/workflows/image.yml)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/ajleal/softether/latest)

## Quick Start

```bash
docker run -d \
  --name softether-vpn-server \
  --restart unless-stopped \
  --cap-add NET_ADMIN \
  -p 443:443/tcp \
  -p 992:992/tcp \
  -p 1194:1194/udp \
  -p 1701:1701/udp \
  -p 500:500/udp \
  -p 4500:4500/udp \
  -p 5555:5555/tcp \
  -v softether_data:/var/lib/softether \
  -v softether_log:/var/log/softether \
  ajleal/softether:latest
```

On first boot, the container initializes SoftEther and prints generated credentials and an OpenVPN client profile to container logs. Treat logs as sensitive.

```bash
docker logs softether-vpn-server
```

## Compose

Use the included [docker-compose.yml](./docker-compose.yml) as a base.

```bash
docker compose up -d
```

## Use `vpncmd`

`vpncmd` is available inside the container:

```bash
docker exec -it softether-vpn-server vpncmd localhost
```

Example VPN client setup:

```bash
docker exec -it softether-vpn-server vpncmd localhost /client

VPN Client> AccountSet homevpn /SERVER:192.168.1.1:443 /HUB:VPN
VPN Client> AccountPasswordSet homevpn /PASSWORD:verysecurepassword /TYPE:standard
VPN Client> AccountConnect homevpn
VPN Client> AccountStartupSet homevpn
VPN Client> AccountStatusGet homevpn
```

## Build Locally

The repository uses a lowercase `dockerfile` filename:

```bash
docker build -f dockerfile -t softether-local .
```

Override base Alpine release if needed:

```bash
docker build -f dockerfile --build-arg ALPINE_VERSION=edge -t softether-local .
```

## Documentation

- [Configuration](./docs/CONFIGURATION.md)
- [Ports and Protocols](./docs/PORTS.md)
- [Operations](./docs/OPERATIONS.md)
- [Troubleshooting](./docs/TROUBLESHOOTING.md)
- [Security](./docs/SECURITY.md)
- [Contributing](./docs/CONTRIBUTING.md)
