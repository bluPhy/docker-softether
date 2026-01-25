#!/bin/bash
set -e

# Mock adduser function
adduser() {
  local user="$1"
  local pass="$2"
  echo "DEBUG: adduser called with user='$user' pass='$pass'"
  if [[ "$pass" != "My P@ssw*rd" ]]; then
    echo "FAIL: Password mismatch. Expected 'My P@ssw*rd', got '$pass'"
    exit 1
  fi
  echo "PASS: Password matches"
}

USERS="testuser:My P@ssw*rd"

echo "Testing user creation loop logic..."

# This simulates the FIXED logic
if [[ $USERS ]]; then
  while IFS=';' read -ra USER; do
    for i in "${USER[@]}"; do
      IFS=':' read -r username password <<<"$i"
      adduser "$username" "$password"
    done
  done <<<"$USERS"
fi
