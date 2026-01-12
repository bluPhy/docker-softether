## 2025-05-18 - Shell Variable Expansion Risks
**Vulnerability:** Unquoted variables in shell scripts caused password truncation and command execution failures.
**Learning:** `read` into an array creates a full array, but accessing `$VAR` only accesses the first element. Also unquoted variables split on spaces, breaking passwords.
**Prevention:** Always quote variable expansions (`"$VAR"`) and iterate arrays explicitly (`for i in "${ARR[@]}"`).
