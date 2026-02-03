## 2025-02-12 - Shell Variable Expansion and Word Splitting
**Vulnerability:** Unquoted variable expansions in shell scripts (`copyables/entrypoint.sh`), specifically `adduser $username $password`, allowed argument injection (splitting passwords with spaces) and globbing (passwords matching filenames).
**Learning:** Shell scripts are vulnerable to word splitting and globbing when variables are not quoted. This can lead to security misconfigurations (weak passwords) or unexpected behavior.
**Prevention:** Always quote variable expansions (`"$var"`) unless word splitting is explicitly intended. Use `read -r` to prevent backslash interpretation. Use `printf " %s" "$var"` to prevent format string injection.
