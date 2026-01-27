## 2025-02-18 - Shell Script Injection via Globbing

**Vulnerability:** Unquoted variable expansion in `entrypoint.sh` used for splitting command strings into arguments also enabled shell globbing (wildcard expansion). If an input contained `*`, it would expand to filenames in the current directory.
**Learning:** Shell scripts often need to split strings into arguments, but unquoted expansion (`$VAR`) does both splitting and globbing. This is a common but subtle vulnerability when handling user input in entrypoint scripts.
**Prevention:** When unquoted expansion is required for argument splitting, wrap the code block in `set -f` (disable globbing) and `set +f`. Ideally, use arrays (`"${arr[@]}"`) which handle arguments safely without splitting or globbing, but this requires the input to be parsed into an array first.
