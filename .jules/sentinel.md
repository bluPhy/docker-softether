## 2024-05-23 - [Variable Quoting in Shell Scripts]
**Vulnerability:** Unquoted variable expansion in `entrypoint.sh` caused passwords with spaces to be truncated when passed to the `adduser` function.
**Learning:** Shell word splitting can silently corrupt data integrity, specifically credentials, leading to weaker passwords than intended. This is often overlooked in "simple" wrapper scripts.
**Prevention:** Always quote variable expansions (`"$var"`) unless word splitting is explicitly required and understood. Use tools like `checkbashisms` or `shellcheck` (though not available here) to detect these issues.
