# Operations

## Persistent Data

Use persistent storage for:

- `/var/lib/softether` (includes `vpn_server.config`)
- `/var/log/softether` (server logs)

Do not rely on `/run/softether` for persistence.

## Startup Lifecycle

1. Container starts.
2. If `/var/lib/softether/vpn_server.config` is missing/empty, bootstrap runs.
3. Bootstrap generates or applies credentials/certificates, enables SecureNAT/OpenVPN/L2TP-IPsec, then writes config.
4. On later restarts, existing config is reused.

## Backup

Named volume example:

```bash
docker run --rm \
  -v softether_data:/from \
  -v "$PWD":/backup \
  busybox \
  sh -lc 'tar czf /backup/softether_data.tgz -C /from .'
```

Bind mount example:

```bash
tar czf softether_data.tgz -C ./softether_data .
```

## Restore

Named volume example:

```bash
docker run --rm \
  -v softether_data:/to \
  -v "$PWD":/backup \
  busybox \
  sh -lc 'tar xzf /backup/softether_data.tgz -C /to'
```

## Upgrade Procedure

1. Pull the target image tag.
2. Stop and remove the running container.
3. Recreate it with the same volume mounts and required options.
4. Verify logs and connectivity.

Example:

```bash
docker pull ajleal/softether:latest
docker stop softether-vpn-server
docker rm softether-vpn-server
# recreate with the same docker run/compose configuration
```

## Reset Bootstrap

To force bootstrap to run again, remove `vpn_server.config` from the persistent data path.

Named volume example:

```bash
docker run --rm -v softether_data:/data busybox rm -f /data/vpn_server.config
```

Warning: this resets container-managed bootstrap settings and credentials.
