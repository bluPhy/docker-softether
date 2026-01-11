# Sentinel's Journal

## 2025-02-12 - Shell Variable Expansion Risks
**Vulnerability:** Passwords containing spaces were being truncated in the entrypoint script due to unquoted variable expansion (`adduser $username $password`).
**Learning:** Shell scripts are prone to word splitting issues that can silently corrupt data like passwords.
**Prevention:** Always quote variables in shell scripts, especially when handling user input or secrets. Use strict linting (shellcheck) where possible.
