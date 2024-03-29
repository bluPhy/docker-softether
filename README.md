# Docker image for SoftEther VPN

This will deploy a fully functional [SoftEther VPN](https://www.softether.org) server as a docker image. Only for the latest RTM version of the product.
Multi platform image: linux/amd64,linux/amd64/v2,linux/arm64,linux/arm/v7

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

    docker run -d --net host --cap-add NET_ADMIN --name softether ajleal/softether

With external config file:

    mkdir /etc/vpnserver
    touch /etc/vpnserver/vpn_server.config
    docker run -d -v /etc/vpnserver/vpn_server.config:/usr/vpnserver/vpn_server.config --net host --cap-add NET_ADMIN --name softether ajleal/softether
