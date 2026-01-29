## 2025-05-23 - Shell Script Variable Quoting and Globbing
**Vulnerability:** Found unquoted variables in `adduser` loop allowing password truncation/corruption (spaces/globs), and `VPNCMD_*` command processing vulnerable to glob injection and logic error (ignoring subsequent commands).
**Learning:** In bash, unquoted variables are subject to word splitting and glob expansion. `read` without `-r` interprets backslashes. Loops over `read` output need careful logic to ensure all input is processed.
**Prevention:** Always quote variables (`"$var"`) unless word splitting is explicitly intended. Use `read -r`. Use `set -f` when relying on word splitting but wanting to avoid globbing. Verify loop logic for multi-line/delimiter processing.
