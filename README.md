# Docker image for SoftEther VPN

This will deploy a fully functional [SoftEther VPN](https://www.softether.org) server as a docker image. Only for the latest RTM version of the product.

**Multi platform image: linux/amd64,linux/amd64/v2,linux/arm64,linux/arm/v7**

Available on [Docker Hub](https://hub.docker.com/r/ajleal/softether/).
Current build version: [SoftEther VPN Stable](https://github.com/SoftEtherVPN/SoftEtherVPN_Stable.git)

![Docker Pulls](https://img.shields.io/docker/pulls/ajleal/softether)

## Build Status

### Github Actions Build

[![Build](https://github.com/bluPhy/docker-softether/actions/workflows/image.yml/badge.svg)](https://github.com/bluPhy/docker-softether/actions/workflows/image.yml)

![Docker Image Size (tag)](https://img.shields.io/docker/image-size/ajleal/softether/latest)

## Download

    docker pull ajleal/softether

## Run

Simplest version:
    This will keep your config and Logfiles in the docker volume ``softetherdata``

    docker run -d --rm --name softether-vpn-server -v softetherdata:/mnt -p 443:443/tcp -p 992:992/tcp -p 1194:1194/udp -p 5555:5555/tcp -p 500:500/udp -p 4500:4500/udp -p 1701:1701/udp --cap-add NET_ADMIN ajleal/softether

### Use vpncmd

With newer releases vpncmd is directly in the container so you can use it to configure vpn. You can can run it once the container is running :

`docker exec -it softether-vpn-server vpncmd localhost`
example to configure a vpnclient

```
docker exec -it softether-vpn-server vpncmd localhost /client

VPN Client> AccountSet homevpn /SERVER:192.168.1.1:443 /HUB:VPN
VPN Client> AccountPasswordSet homevpn /PASSWORD:verysecurepassword /TYPE:standard
VPN Client> AccountConnect homevpn

#Automatically connect once container starts
VPN Client> AccountStartupSet homevpn

#Checking State
VPN Client> AccountStatusGet homevpn

```

