# Contributing

## Scope

This repository builds and publishes a SoftEther VPN Docker image.

Contributions are welcome for:

- Dockerfile/runtime improvements
- startup script reliability and security
- documentation and examples
- CI/release pipeline maintenance

## Local Prerequisites

- Docker
- Docker Buildx
- Docker Compose (optional for local orchestration)

## Build and Smoke Test

Build:

```bash
docker build -f dockerfile -t softether-dev .
```

Basic smoke check:

```bash
docker run --rm --entrypoint sh softether-dev -lc 'ldd /usr/local/bin/vpnserver >/dev/null && echo ok'
```

## Runtime Validation

Recommended quick validation after changes:

```bash
docker run --rm \
  --name softether-test \
  --cap-add NET_ADMIN \
  -p 1194:1194/udp \
  -v softether_test_data:/var/lib/softether \
  -v softether_test_log:/var/log/softether \
  softether-dev
```

Then inspect:

```bash
docker logs softether-test
docker rm -f softether-test
```

## CI Workflow Notes

The workflow file is [`/.github/workflows/image.yml`](../.github/workflows/image.yml).

Pipeline stages:

1. Build local pre-scan image (`linux/amd64`).
2. Run Wiz IaC scan.
3. Run Wiz Docker vulnerability scan.
4. Push multi-platform image on success.

Required repository secrets:

- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`
- `WIZ_CLIENT_ID`
- `WIZ_CLIENT_SECRET`

## Trigger Behavior

Current workflow trigger is push to `master` when these paths change:

- `dockerfile`
- `**.dockerfile`
- `**.sh`

Documentation-only changes do not currently trigger the image pipeline.

## Pull Request Checklist

- Explain why the change is needed.
- Include commands used for local validation.
- Note runtime/security impact.
- Update docs when behavior changes.
