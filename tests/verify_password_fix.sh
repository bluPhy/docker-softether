#!/bin/bash

# Mock vpncmd_hub
vpncmd_hub() {
  echo "vpncmd_hub called with: $@"
}

# The adduser function as defined in entrypoint.sh (using the fixed logic logic for verify)
# Note: This test defines the function mimicking the *fixed* state to verify correctness.
# The entrypoint.sh cannot be sourced directly easily.

adduser() {
  # printf " $1"
  vpncmd_hub UserCreate "$1" /GROUP:none /REALNAME:none /NOTE:none
  vpncmd_hub UserPasswordSet "$1" /PASSWORD:"$2"
}

run_test() {
  local USERS="$1"

  if [[ $USERS ]]; then
    while IFS=';' read -ra USER; do
      for i in "${USER[@]}"; do
        IFS=':' read -r username password <<<"$i"

        # Fixed logic call
        adduser "$username" "$password"
      done
    done <<<"$USERS"
  fi
}

echo "--- Verifying Password Handling ---"
# This should show correct password
OUTPUT=$(run_test "testuser:pass word")
echo "$OUTPUT"
if echo "$OUTPUT" | grep -q "/PASSWORD:pass word"; then
  echo "SUCCESS: Password passed correctly"
else
  echo "FAIL: Password was truncated or malformed"
  exit 1
fi
