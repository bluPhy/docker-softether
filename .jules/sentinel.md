## 2025-02-14 - Bash Word Splitting and Globbing Risks
**Vulnerability:** Command injection and argument parsing flaws in shell scripts due to unquoted variables and lack of globbing control. Specifically, `entrypoint.sh` truncated passwords with spaces and silently ignored multiple commands in `VPNCMD_*` variables.
**Learning:** Shell scripts processing user input via environment variables are prone to word splitting and globbing issues. Iterating over `read -a` arrays requires nested loops.
**Prevention:** Always quote variables (`"$var"`). Use `set -f` before executing dynamic commands that require word splitting but not glob expansion.
