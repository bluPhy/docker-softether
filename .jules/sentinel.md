# Sentinel's Security Journal

## 2025-02-18 - Shell Script Variable Expansion & Read Pitfalls
**Vulnerability:** Shell script variable expansion and input reading logic flaws.
**Learning:** `read` without `-r` interprets backslashes, leading to data corruption (e.g., in passwords). Unquoted array expansion coupled with logic errors can result in incomplete execution of commands (only first command executed in a list).
**Prevention:** Always use `read -r`. Always quote variables. When iterating over lists in shell, verify loop logic and array expansion behavior.
