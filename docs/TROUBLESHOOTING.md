# Troubleshooting

## Container prints `# [!!] This image requires --cap-add NET_ADMIN`

Cause: container cannot access iptables capability checks.  
Fix: run with:

```bash
--cap-add NET_ADMIN
```

## Startup shows `Read-only file system` for THP/sysctl lines

At startup, entrypoint tries to:

- write `/sys/kernel/mm/transparent_hugepage/enabled`
- set `net.core.somaxconn`

Some runtimes block these operations.  
If VPN functions are otherwise healthy, these warnings are usually non-fatal.

## No credentials/profile printed after restart

Bootstrap output is only printed when `vpn_server.config` is missing or empty.

If config already exists, startup logs show `# [running with existing config]`.

## Users from `USERS` are not created as expected

`USERS` must be a semicolon-separated list of `user:password` pairs:

```bash
USERS='alice:pass1;bob:pass2'
```

Avoid semicolons and unescaped colons inside usernames/passwords.

## L2TP clients fail to connect

Check:

1. UDP ports `500`, `4500`, and `1701` are published and allowed by firewalls.
2. `PSK` value used by clients matches server value.
3. Port `1701` is mapped as UDP, not TCP.

## OpenVPN profile not generated in logs

OpenVPN profile output is printed during first bootstrap only.

If bootstrap has already completed, either:

- reset bootstrap by removing `vpn_server.config`, or
- generate/export client settings manually with `vpncmd`.

## `gencert` command fails with missing `/gencert.sh`

Current Dockerfile copies only `/entrypoint.sh` from `copyables/`; `/gencert.sh` is not included in the runtime image.  
Use `CERT` and `KEY` environment variables directly, or build a custom image that copies `copyables/gencert.sh`.
