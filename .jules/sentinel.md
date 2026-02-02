## 2025-02-02 - Unquoted Variable Expansion in Entrypoint Scripts
**Vulnerability:** Command injection and argument hijacking via unquoted variables in shell scripts.
**Learning:** Shell variables passed to functions or commands without quotes are subject to word splitting and globbing. In `entrypoint.sh`, `adduser $username $password` allowed a password containing globs (e.g., `*`) to expand to filenames, or spaces to shift arguments.
**Prevention:** Always quote variable expansions (`"$var"`). For dynamic commands where word splitting is desired but globbing is not, use `set -f` before execution and `set +f` after.
