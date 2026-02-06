## 2025-05-18 - Shell Script Injection Risks via Unquoted Variables
**Vulnerability:** Unquoted variables in `entrypoint.sh` allowed argument splitting (passwords with spaces) and glob expansion (passwords with wildcards matching filenames).
**Learning:** Shell scripts are vulnerable to implicit expansion. `password="secret *"` expanded to filenames if unquoted, potentially exposing file existence or leaking data if passed to a command that prints arguments.
**Prevention:** Always quote variables (`"$VAR"`). Use `read -r` to disable backslash interpretation. Use `printf " %s" "$VAR"` to avoid format string injection.
