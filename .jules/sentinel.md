## 2024-05-22 - [Shell Script Injection in Entrypoint]
**Vulnerability:** Unquoted variable expansion in `entrypoint.sh` allowed password truncation (via spaces) and file path disclosure/injection (via globbing `*`) when processing `USERS` and `VPNCMD_*` environment variables.
**Learning:** Shell scripts processing list-like environment variables (e.g., semicolon-separated users) must strictly handle delimiter splitting without triggering shell expansions on the content.
**Prevention:** Always use `read -r` for input processing. Quote all variable expansions (`"$var"`). If word splitting is required (e.g., for command arguments), use `set -f` (noglob) to safely allow splitting without globbing.
