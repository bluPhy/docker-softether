## 2026-01-25 - Insecure Shell Variable Expansion
**Vulnerability:** Unquoted variables and `read` without `-r` in entrypoint scripts caused password truncation and potential command injection.
**Learning:** Shell variables containing user input (passwords, commands) are subject to word splitting and globbing if not quoted.
**Prevention:** Always quote variables (`"$var"`), use `read -r`, and use `set -f` when splitting strings is required but globbing is not.
