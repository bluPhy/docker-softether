## 2025-02-18 - Shell Script Variable Quoting and Globbing
**Vulnerability:** Unquoted variables in shell scripts (specifically `entrypoint.sh`) caused data loss (truncated passwords) and introduced globbing vulnerabilities (expanding `*` to filenames in dynamic commands).
**Learning:** Shell scripts processing complex environment variables (like semicolon-separated lists of commands or credentials) are highly prone to parsing errors if variable expansion is not strictly controlled. Standard `read` interprets backslashes, and unquoted variable expansion triggers word splitting and globbing.
**Prevention:**
1. Always use `read -r` to prevent backslash interpretation.
2. Always quote variables (`"$var"`) to prevent word splitting, unless splitting is explicitly intended.
3. If word splitting is intended (e.g., parsing a command string), wrap the execution in `set -f; ...; set +f` to prevent unintended globbing.
4. Use `printf " %s" "$var"` instead of `printf " $var"` to avoid format string injection.
