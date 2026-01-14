# Sentinel Security Journal

## 2025-05-19 - Shell Variable Quoting in Entrypoint
**Vulnerability:** Unquoted variables in `entrypoint.sh` caused password truncation when passwords contained spaces. Specifically, `adduser $username $password` split passwords like "my secret" into multiple arguments.
**Learning:** Shell scripts processing user input via environment variables are highly susceptible to word splitting and globbing if variables are not rigorously quoted. In this case, it wasn't just a stability issue but a security one (password integrity).
**Prevention:** Always quote variables (`"$VAR"`) in shell scripts. Use `read -r` to prevent backslash interpretation.
