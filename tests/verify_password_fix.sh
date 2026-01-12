#!/bin/bash

# This script verifies the fix for password truncation and command loops in entrypoint.sh logic.
# It mocks the vpncmd wrapper functions and executes the relevant logic extracted from entrypoint.sh.

FAILures=0

mock_vpncmd_hub() {
  echo "MOCK_HUB: $@"
}

mock_vpncmd_server() {
  echo "MOCK_SERVER: $@"
}

adduser() {
    # Mocking the adduser function from entrypoint.sh
    # We want to ensure that $2 (password) is received fully
    printf " $1"
    mock_vpncmd_hub UserCreate "$1" /GROUP:none /REALNAME:none /NOTE:none
    mock_vpncmd_hub UserPasswordSet "$1" /PASSWORD:"$2"
}

# Test 1: Password with spaces
echo "TEST 1: Password with spaces"
USERS="alice:secret pass word"
OUTPUT=$(
    while IFS=';' read -ra USER; do
        for i in "${USER[@]}"; do
        IFS=':' read username password <<<"$i"
        adduser "$username" "$password"
        done
    done <<<"$USERS"
)

echo "$OUTPUT"
if echo "$OUTPUT" | grep -q "/PASSWORD:secret pass word"; then
    echo "PASS: Password correctly preserved."
else
    echo "FAIL: Password truncated."
    FAILures=$((FAILures+1))
fi

# Test 2: VPNCMD_SERVER loop
echo "TEST 2: VPNCMD_SERVER loop"
VPNCMD_SERVER="ServerCipherSet AES;LogDisable security"
vpncmd_server() { mock_vpncmd_server "$@"; }

OUTPUT=$(
    if [[ $VPNCMD_SERVER ]]; then
        while IFS=";" read -ra CMDS; do
        for CMD in "${CMDS[@]}"; do
            vpncmd_server $CMD
        done
        done <<<"$VPNCMD_SERVER"
    fi
)

echo "$OUTPUT"
if echo "$OUTPUT" | grep -q "ServerCipherSet AES" && echo "$OUTPUT" | grep -q "LogDisable security"; then
    echo "PASS: Both commands executed."
else
    echo "FAIL: Commands missing."
    FAILures=$((FAILures+1))
fi

exit $FAILures
