## 2025-05-15 - Shell Script Variable Quoting & Command Injection
**Vulnerability:** Unquoted variables in shell scripts (`$VAR` instead of `"$VAR"`) allowed word splitting and glob expansion.
**Learning:**
1. Parsing `USERS` without quoting led to password truncation if spaces were present. Fixed by quoting.
2. `VPNCMD_SERVER` was intended to execute commands with arguments (requiring word splitting) but vulnerable to glob expansion (e.g. `*`). Quoting it (`"$CMD"`) broke argument parsing.
**Prevention:**
- For variables containing data (passwords, usernames): ALWAYS quote (`"$VAR"`).
- For variables containing commands to be executed (where arguments must be split):
  - Use `set -f` (noglob) to disable glob expansion.
  - Use unquoted expansion (`$cmd`) to allow word splitting.
  - Re-enable globbing with `set +f` if needed.
