## 2025-05-15 - Shell Script Input Handling Vulnerabilities
**Vulnerability:** Found unquoted variable expansions and `read` without `-r` in `entrypoint.sh`, causing passwords with spaces/backslashes to be corrupted and creating risk of globbing expansion from file system contents.
**Learning:** Bash `read` loop combined with `<<<` string input requires careful array handling to process multiple commands correctly. Unquoted expansion for argument splitting is risky and requires `set -f` (noglob).
**Prevention:** Enforce `read -r` and variable quoting in all shell scripts. When splitting strings into arguments is necessary, explicitly disable globbing with `set -f`.
