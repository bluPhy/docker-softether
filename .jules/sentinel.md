## 2024-11-26 - Shell Script Injection Patterns
**Vulnerability:** Widespread unquoted variables and unsafe `read` usage in `entrypoint.sh` allowed for argument injection (word splitting), file enumeration (globbing), and data corruption (backslash stripping).
**Learning:** The codebase used `while read` loops on variables containing semicolons without properly handling array iteration or disabling globbing, leading to both functional bugs (ignoring subsequent commands) and security risks.
**Prevention:**
1. Always quote variable expansions: `"$VAR"`.
2. Use `read -r` to disable backslash escaping.
3. To safely split strings into arguments without globbing: `set -f; command $args; set +f`.
4. Use `printf " %s" "$var"` instead of `printf " $var"` to prevent format string attacks.
