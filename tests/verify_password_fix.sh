#!/bin/bash
set -e

# Mock functions
adduser() {
  echo "ADDUSER_CALLED: '$1' '$2'"
}

vpncmd_server() {
  echo "VPNCMD_SERVER_CALLED: $@"
}

vpncmd_hub() {
  echo "VPNCMD_HUB_CALLED: $@"
}

# Setup test environment
touch pass
touch match_me

FAILED=0

# Test 1: Password with spaces and backslashes
USERS="user1:pass word;user2:pass\word;user3:pass*"
echo "Testing USERS parsing..."

OUTPUT=$(
  if [[ $USERS ]]; then
    while IFS=';' read -r -a USER_ARR; do
      for i in "${USER_ARR[@]}"; do
        IFS=':' read -r username password <<<"$i"
        adduser "$username" "$password"
      done
    done <<<"$USERS"
  fi
)

EXPECTED="ADDUSER_CALLED: 'user1' 'pass word'
ADDUSER_CALLED: 'user2' 'pass\word'
ADDUSER_CALLED: 'user3' 'pass*'"

if [[ "$OUTPUT" != "$EXPECTED" ]]; then
  echo "FAIL: USERS parsing mismatch"
  echo "Expected:"
  echo "$EXPECTED"
  echo "Got:"
  echo "$OUTPUT"
  FAILED=1
else
  echo "PASS: USERS parsing"
fi

# Test 2: Multiple commands
VPNCMD_SERVER="cmd1 arg1;cmd2 arg2;cmd3 *"
echo "Testing VPNCMD_SERVER processing..."

OUTPUT=$(
  if [[ $VPNCMD_SERVER ]]; then
    while IFS=";" read -r -a CMDS; do
      for cmd in "${CMDS[@]}"; do
          set -f
          vpncmd_server $cmd
          set +f
      done
    done <<<"$VPNCMD_SERVER"
  fi
)

EXPECTED="VPNCMD_SERVER_CALLED: cmd1 arg1
VPNCMD_SERVER_CALLED: cmd2 arg2
VPNCMD_SERVER_CALLED: cmd3 *"

if [[ "$OUTPUT" != "$EXPECTED" ]]; then
  echo "FAIL: VPNCMD_SERVER parsing mismatch"
  echo "Expected:"
  echo "$EXPECTED"
  echo "Got:"
  echo "$OUTPUT"
  FAILED=1
else
  echo "PASS: VPNCMD_SERVER processing"
fi

# Cleanup
rm pass match_me

if [[ $FAILED -eq 1 ]]; then
  exit 1
fi
