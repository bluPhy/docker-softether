# Docker image for SoftEther VPN

This will deploy a fully functional [SoftEther VPN](https://www.softether.org) server as a docker image. Only for the latest RTM version of the product.

Available on [Docker Hub](https://hub.docker.com/r/ajleal/softether/).

Current build version: SoftEther VPN v4.38-9760-rtm-2021.08.17

## Download

    docker pull ajleal/softether

## Run

Simplest version:

    docker run -d --net host --cap-add NET_ADMIN --name softether ajleal/softether

With external config file:

    mkdir /etc/vpnserver
    touch /etc/vpnserver/vpn_server.config
    docker run -d -v /etc/vpnserver/vpn_server.config:/usr/local/vpnserver/vpn_server.config --net host --cap-add NET_ADMIN --name softether ajleal/softether

If you want to keep the logs in a data container:

    docker volume create --name softether-logs
    docker run -d --net host --cap-add NET_ADMIN --name softether -v softether-logs:/var/log/vpnserver ajleal/softether

All together now:

    touch /etc/vpnserver/vpn_server.config
    docker volume create --name softether-logs
    docker run -d -v /etc/vpnserver/vpn_server.config:/usr/local/vpnserver/vpn_server.config  -v softether-logs:/var/log/vpnserver --net host --cap-add NET_ADMIN --name softether ajleal/softether
