## 2025-01-21 - Unquoted Variable Expansion in Command Loop
**Vulnerability:** Shell globbing injection in dynamic command execution.
**Learning:** In Bash, iterating over commands provided as a string requires careful handling of word splitting vs. filename expansion. Using `$VAR` (unquoted) allows both. If the input contains `*`, it expands to filenames, potentially altering the command arguments unintentionally.
**Prevention:** Use `set -f` (disable globbing) before expanding unquoted variables when only word splitting is desired, or parse arguments into an array properly if the format allows.
