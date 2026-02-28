# Configuration

This image bootstraps configuration only when `/var/lib/softether/vpn_server.config` is missing or empty.

If that file already exists, the container starts with the existing config and skips initialization.

## Environment Variables

All variables below are read by [`copyables/entrypoint.sh`](../copyables/entrypoint.sh) during bootstrap.

| Variable | Default | Description |
|---|---|---|
| `PSK` | Random 20-char alphanumeric | IPsec pre-shared key used in `IPsecEnable`. |
| `USERS` | unset | Semicolon-separated `user:password` pairs, for example `alice:pass1;bob:pass2`. |
| `USERNAME` | `userNNNN` | Single user name when `USERS` is not set. |
| `PASSWORD` | Random generated value | Password for `USERNAME` when `USERS` is not set. |
| `MTU` | `1500` | SecureNAT MTU value (`NatSet`). |
| `CERT` | unset | Certificate body (PEM content without headers/newlines) used with `KEY`. |
| `KEY` | unset | Private key body (PEM content without headers/newlines) used with `CERT`. |
| `VPNCMD_SERVER` | unset | Semicolon-separated `vpncmd /SERVER` commands to execute during bootstrap. |
| `VPNCMD_HUB` | unset | Semicolon-separated `vpncmd /HUB:DEFAULT` commands to execute during bootstrap. |
| `HPW` | Random 16-char alphanumeric | Hub password (`SetHubPassword`). |
| `SPW` | Random 20-char alphanumeric | Server password (`ServerPasswordSet`). |

## Example: Preseed Basic Credentials

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
  -e PSK='replace-with-strong-psk' \
  -e USERS='alice:changeMe1;bob:changeMe2' \
  -e HPW='replaceHubPassword' \
  -e SPW='replaceServerPassword' \
  ajleal/softether:latest
```

## Example: Run Extra `vpncmd` Commands on First Boot

```bash
docker run -d \
  --name softether-vpn-server \
  --cap-add NET_ADMIN \
  -v softether_data:/var/lib/softether \
  -v softether_log:/var/log/softether \
  -e VPNCMD_SERVER='ListenerCreate 4443;IPsecEnable /L2TP:yes /L2TPRAW:yes /ETHERIP:no /PSK:yourpsk /DEFAULTHUB:DEFAULT' \
  -e VPNCMD_HUB='SecureNatEnable;DhcpSet /START:192.168.30.10 /END:192.168.30.200 /MASK:255.255.255.0 /EXPIRE:7200 /GW:192.168.30.1 /DNS:1.1.1.1 /DNS2:8.8.8.8 /DOMAIN:none /LOG:no' \
  ajleal/softether:latest
```

## Certificate Input Format

For `CERT` and `KEY`, pass only the base64 body content (no PEM header/footer lines).  
The entrypoint reconstructs PEM files internally before applying them.

## Startup Hooks

On every container start, if `/opt/scripts/` exists, all `*.sh` files are executed in lexical order.

Use this for custom post-start automation:

```bash
-v ./scripts:/opt/scripts:ro
```
