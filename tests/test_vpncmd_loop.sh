#!/bin/bash
set -e

# Mock vpncmd_server
vpncmd_server() {
  echo "EXECUTED: $*"
}

VPNCMD_SERVER="Cmd1 arg1;Cmd2 arg2"
EXPECTED_OUTPUT="EXECUTED: Cmd1 arg1
EXECUTED: Cmd2 arg2"

echo "Testing VPNCMD loop logic..."

# Capture output
OUTPUT=$(
  if [[ $VPNCMD_SERVER ]]; then
    IFS=';' read -ra CMDS <<< "$VPNCMD_SERVER"
    for CMD in "${CMDS[@]}"; do
       # Trim leading/trailing whitespace (optional but good)
       # For this test, we assume clean input or that spaces are part of the command
       vpncmd_server $CMD
    done
  fi
)

echo "Output:"
echo "$OUTPUT"

if [[ "$OUTPUT" == *"$EXPECTED_OUTPUT"* ]]; then
    echo "PASS: All commands executed"
else
    echo "FAIL: Output mismatch"
    exit 1
fi
