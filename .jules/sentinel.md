## 2025-02-18 - Shell Variable Expansion Vulnerabilities
**Vulnerability:** Unquoted shell variables in `entrypoint.sh` allowed password truncation (via word splitting) and file globbing (via `*` expansion).
**Learning:** Shell scripts processing user input via `read` and variable expansion must strictly quote variables and use `read -r` to prevent data corruption and injection. Relying on word splitting for command parsing is dangerous without `set -f`.
**Prevention:** Always quote variables (`"$var"`), use `read -r`, and disable globbing (`set -f`) when word splitting is explicitly required.
