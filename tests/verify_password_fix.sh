#!/bin/bash
# Mock adduser and verify arguments
adduser() {
  if [[ "$2" == "secret pass" ]]; then
    echo "SUCCESS: Password verified correctly: '$2'"
  else
    echo "FAILURE: Password mismatch: '$2'"
    exit 1
  fi
}

USERS="alice:secret pass"
# Extract the logic from entrypoint.sh (simplified)
while IFS=';' read -ra USER; do
  for i in "${USER[@]}"; do
    IFS=':' read username password <<<"$i"
    adduser "$username" "$password"
  done
done <<<"$USERS"
