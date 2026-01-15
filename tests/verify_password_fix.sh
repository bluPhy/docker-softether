#!/bin/bash
# Test script to verify that password handling and variable quoting is correct.

# Mock functions
vpncmd_hub() {
  echo "MOCK_VPNCMD_HUB: ($# args) $@"
}

vpncmd_server() {
  echo "MOCK_VPNCMD_SERVER: ($# args) $@"
}

adduser() {
  # Logic from entrypoint.sh
  # printf " $1"
  vpncmd_hub UserCreate "$1" /GROUP:none /REALNAME:none /NOTE:none
  vpncmd_hub UserPasswordSet "$1" /PASSWORD:"$2"
}

FAIL=0

echo "Running security regression tests..."

# 1. Test USERS with spaces in password
# Expectation: 2 args for UserPasswordSet: [testuser] [/PASSWORD:secret password]
# Wait, original script calls: vpncmd_hub UserPasswordSet "$1" /PASSWORD:"$2"
# That's 2 args: "UserPasswordSet" (implicit cmd?), actually vpncmd_hub takes "$@" and puts it after /CMD.
# So `vpncmd_hub UserPasswordSet "$1" ...`
# Args passed to vpncmd_hub: "UserPasswordSet" "testuser" "/PASSWORD:secret password" ...
# Total args: 1 + 1 + 1 = 3 (plus others).
# The mock prints "$@".

USERS="testuser:secret password"
OUTPUT=$(
  if [[ $USERS ]]; then
      while IFS=';' read -r -a USER; do
        for i in "${USER[@]}"; do
          IFS=':' read -r username password <<<"$i"
          adduser "$username" "$password"
        done
      done <<<"$USERS"
  fi
)

# We check for the password string.
if echo "$OUTPUT" | grep -q "MOCK_VPNCMD_HUB:.*\/PASSWORD:secret password"; then
  echo "PASS: Password with spaces handled correctly."
else
  echo "FAIL: Password with spaces NOT handled correctly."
  echo "Output was: $OUTPUT"
  FAIL=1
fi

# 2. Test VPNCMD_SERVER with glob AND multiple args
# Case A: "LogGet *" -> Should be "LogGet" "*" (2 args), but * not expanded.
# Case B: "UserCreate bob" -> Should be "UserCreate" "bob" (2 args).
VPNCMD_SERVER="UserCreate bob;LogGet *"
# Create dummy files
touch testfile1 testfile2

# Need to implement the fix logic here to test it.
# Current logic in entrypoint.sh (the one I submitted) is:
# while IFS=";" read -r -a CMD; do vpncmd_server "$CMD"; done ...
# This logic fails Case B (passes 1 arg "UserCreate bob").

# Improved logic I plan to implement:
OUTPUT=$(
  if [[ $VPNCMD_SERVER ]]; then
    # Fix the loop to handle multiple commands correctly
    IFS=";" read -r -a CMDS <<<"$VPNCMD_SERVER"
    for cmd in "${CMDS[@]}"; do
       # Disable globbing
       set -f
       # Allow word splitting (unquoted)
       vpncmd_server $cmd
       # Re-enable globbing
       set +f
    done
  fi
)
rm testfile1 testfile2

echo "$OUTPUT"

# Verify Case A
# Expect: LogGet * (2 args)
if echo "$OUTPUT" | grep -q "MOCK_VPNCMD_SERVER: (2 args) LogGet \*"; then
  echo "PASS: Glob * passed literally as separate arg."
else
  echo "FAIL: Glob * check failed."
  FAIL=1
fi

# Verify Case B
# Expect: UserCreate bob (2 args)
if echo "$OUTPUT" | grep -q "MOCK_VPNCMD_SERVER: (2 args) UserCreate bob"; then
  echo "PASS: Command with args passed as separate args."
else
  echo "FAIL: Command with args check failed (likely passed as single arg)."
  FAIL=1
fi

if [[ $FAIL -eq 0 ]]; then
  echo "All tests passed."
  exit 0
else
  echo "Some tests failed."
  exit 1
fi
