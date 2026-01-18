#!/bin/bash

# Mock adduser function to verify arguments
adduser() {
  if [ "$1" == "user1" ] && [ "$2" == "pass word" ]; then
    echo "SUCCESS: user1 created with correct password."
  else
    echo "FAILURE: user1 created with incorrect arguments: '$1', '$2'"
    exit 1
  fi
}

USERS="user1:pass word"
echo "Testing with USERS='$USERS'"

if [[ $USERS ]]; then
    while IFS=';' read -r -a USER; do
      for i in "${USER[@]}"; do
        IFS=':' read -r username password <<<"$i"
        adduser "$username" "$password"
      done
    done <<<"$USERS"
fi
