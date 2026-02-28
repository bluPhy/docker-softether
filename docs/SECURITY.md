# Security

## Reporting Vulnerabilities

If you discover a security issue in this image or repository:

1. Prefer private disclosure through GitHub Security Advisories.
2. Include reproduction steps, affected tags/architectures, and impact details.
3. Avoid posting exploit details publicly before maintainers can respond.

## Image Hardening Notes

Current build hardening includes:

- Multi-stage image build.
- `apk upgrade --no-cache` during build and runtime package installation.
- Minimal runtime packages for SoftEther operation.

## Operational Security Recommendations

- Pin image tags or digests in production.
- Keep persisted config/log volumes access-controlled.
- Treat container logs as sensitive on first bootstrap (credentials and client profile are printed).
- Limit exposed ports to only the protocols you use.
- Keep `5555/tcp` restricted to trusted networks when possible.

## Secret Handling

You can provide credentials/cert material through environment variables (`PSK`, `USERS`, `CERT`, `KEY`, `HPW`, `SPW`), but avoid leaking them via shell history or process listings.

Prefer:

- secret managers,
- environment files with restricted permissions,
- and short-lived provisioning flows.

## Supply Chain and CI

GitHub Actions workflow performs:

- buildx pre-scan build,
- Wiz IaC scan,
- Wiz container vulnerability scan,
- then multi-platform push on success.

See [`/.github/workflows/image.yml`](../.github/workflows/image.yml).
