# Sentinel Security Journal

## 2024-05-22 - Shell Script Injection & Credential Mishandling
**Vulnerability:** The `entrypoint.sh` script used unquoted variables (`$username`, `$password`) when passing credentials to `adduser` and `vpncmd`. This caused passwords with spaces to be truncated or misinterpreted. Additionally, `read` without `-r` stripped backslashes from passwords. Dynamic command execution (`$CMD`) was vulnerable to globbing.
**Learning:** Container initialization scripts ("glue code") are a critical attack surface often overlooked during security reviews. They handle sensitive secrets (initial passwords) but often lack the defensive coding practices applied to application code.
**Prevention:**
1. Always quote variables in shell scripts: `"$var"`.
2. Always use `read -r` to preserve backslashes.
3. Use `set -f` before expanding unquoted variables intended for command splitting to prevent globbing.
4. Integrate `shellcheck` into the build pipeline.
