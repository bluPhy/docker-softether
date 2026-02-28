# Ports and Protocols

## Port Matrix

| Port | Protocol | Purpose | Typical Use |
|---|---|---|---|
| `443` | TCP | SoftEther listener (VPN over HTTPS/TLS) | Common primary VPN endpoint |
| `992` | TCP | SoftEther listener | Alternate SoftEther port |
| `1194` | UDP | OpenVPN listener configured by entrypoint | OpenVPN clients |
| `1194` | TCP | Exposed by image, optional mapping | Optional OpenVPN/TCP style deployment |
| `1701` | UDP | L2TP control channel | L2TP/IPsec clients |
| `500` | UDP | IKE (IPsec) | L2TP/IPsec setup |
| `4500` | UDP | IPsec NAT-T | L2TP/IPsec behind NAT |
| `5555` | TCP | SoftEther management/listener port | Admin/client connectivity (optional externally) |

## Recommended Publishing

For typical L2TP/IPsec + OpenVPN use:

```bash
-p 443:443/tcp \
-p 992:992/tcp \
-p 1194:1194/udp \
-p 1701:1701/udp \
-p 500:500/udp \
-p 4500:4500/udp \
-p 5555:5555/tcp
```

## Firewall Notes

- Allow both inbound and return traffic for UDP ports `500`, `4500`, `1701`, and `1194`.
- If only one VPN protocol is required, restrict exposed ports accordingly.
- Keep `5555/tcp` private when possible.

## `docker-compose.yml` Note

The repository compose file currently maps `1701` as TCP.  
If you need L2TP/IPsec compatibility, map it as UDP (`1701:1701/udp`).
