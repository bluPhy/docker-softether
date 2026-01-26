## 2025-02-12 - [Shell Script Injection & Parsing Risks]
**Vulnerability:** Found unquoted variable expansions and unsafe iteration over user inputs in `entrypoint.sh`. Specifically, `adduser $username $password` allowed word splitting and globbing on passwords, and `read -ra` loop for `VPNCMD_*` executed only the first command and was vulnerable to globbing.
**Learning:** Shell scripts processing untrusted input (like passwords or configuration strings) must rigorously quote variables and use `read -r`. When splitting strings for command execution (like `VPNCMD`), standard arrays are tricky; we must ensure we iterate over all elements and control globbing (`set -f`) if we rely on word splitting for arguments.
**Prevention:**
1. Always quote variables: `"$var"`.
2. Use `read -r` to prevent backslash interpretation.
3. For dynamic command execution where arguments need splitting but not globbing, use `set -f; cmd $args; set +f`.
