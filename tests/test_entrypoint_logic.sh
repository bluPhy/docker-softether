#!/bin/bash

# Test script for entrypoint.sh logic
# We will source a modified version of the relevant logic or mock the environment

# Mock vpncmd_server and vpncmd_hub
vpncmd_server() {
  echo "vpncmd_server called with args: $@"
}

vpncmd_hub() {
  echo "vpncmd_hub called with args: $@"
}

test_command_execution() {
  echo "Testing command execution logic..."

  # Create a file that would match a glob if globbing were enabled
  touch glob_test_file

  export VPNCMD_SERVER="cmd1 arg1;cmd2 *"

  # Extract the logic block we want to test
  # We can't source entrypoint.sh directly because it runs commands immediately.
  # So we will replicate the logic we just wrote to verify it works in isolation.

  echo "Running logic..."
  if [[ $VPNCMD_SERVER ]]; then
    while IFS=";" read -ra CMDS; do
      for CMD in "${CMDS[@]}"; do
        set -f
        vpncmd_server $CMD
        set +f
      done
    done <<<"$VPNCMD_SERVER"
  fi

  rm glob_test_file
}

output=$(test_command_execution)

echo "$output"

if echo "$output" | grep -q "vpncmd_server called with args: cmd1 arg1" && \
   echo "$output" | grep -q "vpncmd_server called with args: cmd2 \*"; then
  echo "SUCCESS: Both commands executed and glob was NOT expanded."
else
  echo "FAILURE: Output did not match expected behavior."
  exit 1
fi
