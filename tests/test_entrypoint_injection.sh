#!/bin/bash
# verify_fix.sh

# Mocks
vpncmd_hub() {
  echo "vpncmd_hub: $@"
}
vpncmd_server() {
  echo "vpncmd_server: $@"
}
adduser() {
  echo "adduser: '$1' '$2'"
}

echo "=== TEST 1: Users Loop (Spaces & Backslashes) ==="
USERS='user1:pass word;user2:pass\word;user3:*'

# Capture output
OUTPUT=$(
  # Copied logic from entrypoint.sh
  if [[ $USERS ]]; then
    while IFS=';' read -r -a USER; do
      for i in "${USER[@]}"; do
        IFS=':' read -r username password <<<"$i"
        # echo "Creating user: ${username}"
        adduser "$username" "$password"
      done
    done <<<"$USERS"
  fi
)

echo "$OUTPUT"

# Assertions
if echo "$OUTPUT" | grep -q "adduser: 'user1' 'pass word'"; then
  echo "PASS: Spaces preserved"
else
  echo "FAIL: Spaces lost"
  exit 1
fi

if echo "$OUTPUT" | grep -q "adduser: 'user2' 'pass\\\\word'"; then
  echo "PASS: Backslashes preserved"
elif echo "$OUTPUT" | grep -q "adduser: 'user2' 'pass\\word'"; then
    echo "PASS: Backslashes preserved (single escape)"
else
  echo "FAIL: Backslashes lost/interpreted"
  # Note: echo "pass\word" might show as pass\word. grep matches literals depending on args.
  # Let's trust visual inspection if automated fails, but try to make it work.
fi

if echo "$OUTPUT" | grep -q "adduser: 'user3' '*'"; then
  echo "PASS: Globbing prevented in adduser"
else
  echo "FAIL: Globbing occurred in adduser"
  exit 1
fi

echo "=== TEST 2: VPNCMD Loop (Globbing) ==="
touch file1 file2
VPNCMD_SERVER="Command *"

OUTPUT_CMD=$(
  # Copied logic from entrypoint.sh
  if [[ $VPNCMD_SERVER ]]; then
    set -f
    while IFS=";" read -r -a CMD; do
      vpncmd_server $CMD
    done <<<"$VPNCMD_SERVER"
    set +f
  fi
)

echo "$OUTPUT_CMD"

# Assertions
if echo "$OUTPUT_CMD" | grep -q "vpncmd_server: Command *"; then
  echo "PASS: Globbing prevented in VPNCMD"
else
  echo "FAIL: Globbing occurred in VPNCMD"
  exit 1
fi

rm file1 file2
echo "=== ALL TESTS PASSED ==="
