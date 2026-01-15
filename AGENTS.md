# Agent Instructions

## Shell Scripts
- **Quoting**: All variable expansions MUST be quoted (e.g., `"$VAR"`) to prevent word splitting and globbing, unless explicit splitting is required.
- **`read`**: Always use `read -r` to prevent backslash interpretation unless specifically desired.
- **Testing**: Use `bash -n` to verify syntax. Run `tests/verify_password_fix.sh` to ensure regression testing for credential handling.
