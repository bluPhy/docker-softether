#!/bin/bash
set -u

TEST_DIR=$(mktemp -d)
ENTRYPOINT_SCRIPT="$TEST_DIR/entrypoint.sh"
MOCK_BIN="$TEST_DIR/bin"
MOCK_VPNCMD="$MOCK_BIN/vpncmd"
MOCK_VPNSERVER="$MOCK_BIN/vpnserver"
MOCK_CONFIG="$TEST_DIR/vpn_server.config"
LOG_FILE="$TEST_DIR/vpncmd.log"

# Cleanup on exit
trap "rm -rf $TEST_DIR" EXIT

# 1. Setup Mock Environment
mkdir -p "$MOCK_BIN"

# Create mock vpncmd
cat <<EOF > "$MOCK_VPNCMD"
#!/bin/bash
# Log arguments to file
echo "ARGS: \$@" >> "$LOG_FILE"
EOF
chmod +x "$MOCK_VPNCMD"

# Create mock vpnserver
cat <<EOF > "$MOCK_VPNSERVER"
#!/bin/bash
if [ "\$1" == "start" ]; then
  # Simulate server running in background
  sleep 1 &
fi
EOF
chmod +x "$MOCK_VPNSERVER"

# 2. Prepare entrypoint script
# Copy original script
cp copyables/entrypoint.sh "$ENTRYPOINT_SCRIPT"

# Modify script to use mocks and local config
# Replace /usr/local/bin/vpncmd with our mock
sed -i "s|/usr/local/bin/vpncmd|$MOCK_VPNCMD|g" "$ENTRYPOINT_SCRIPT"
# Replace /usr/local/bin/vpnserver with our mock
sed -i "s|/usr/local/bin/vpnserver|$MOCK_VPNSERVER|g" "$ENTRYPOINT_SCRIPT"
# Replace config path
sed -i "s|/var/lib/softether/vpn_server.config|$MOCK_CONFIG|g" "$ENTRYPOINT_SCRIPT"

# Make sure iptables check doesn't block us (mock iptables if needed, or rely on the script continuing)
# The script has:
# iptables -L 2>/dev/null >/dev/null
# if [[ $? -ne 0 ]]; then ... fi
# It doesn't exit, just warns. So we are fine.

# 3. Create dummy file to test globbing
touch "$TEST_DIR/dummy_file_glob_match"
cd "$TEST_DIR" # Change to test dir so globbing works here

# 4. Run the test case
export USERS="user_space:pass word;user_glob:*"
export VPNCMD_SERVER="HubCreate myhub /PASSWORD:*"

# Run entrypoint.sh (it might take some time due to sleeps, so we might want to kill it or modify sleeps)
# We can reduce sleeps in the script using sed
sed -i 's/sleep [0-9]*/sleep 0/g' "$ENTRYPOINT_SCRIPT"

# Run it. It will try to loop waiting for server.
# Our mock vpnserver just exits.
# The entrypoint script waits for vpnserver to start:
# while :; do ... vpncmd_server ... [[ $? -eq 0 ]] && break ... done
# Our mock vpncmd always returns 0 (echo succeeds). So it should break immediately.
# Then it does a bunch of vpncmd calls.
# Then it stops vpnserver.

bash "$ENTRYPOINT_SCRIPT" >/dev/null 2>&1

# 5. Verify Results
echo "Checking results in $LOG_FILE"
cat "$LOG_FILE"

FAILED=0

# Check user_space password
if grep -q "UserPasswordSet user_space /PASSWORD:pass word" "$LOG_FILE"; then
  echo "PASS: Password with space preserved (or at least passed as arguments)"
else
  echo "FAIL: Password with space NOT preserved correctly or truncated"
  grep "UserPasswordSet user_space" "$LOG_FILE" || echo "  (not found)"
  FAILED=1
fi

# Check user_glob password
if grep -q "UserPasswordSet user_glob /PASSWORD:*" "$LOG_FILE"; then
  echo "PASS: Password '*' preserved"
else
  echo "FAIL: Password '*' was expanded or modified"
  grep "UserPasswordSet user_glob" "$LOG_FILE" || echo "  (not found)"
  FAILED=1
fi

# Check VPNCMD_SERVER globbing
# If globbing happened, we might see "dummy_file_glob_match" in the args
if grep -q "dummy_file_glob_match" "$LOG_FILE"; then
  echo "FAIL: VPNCMD_SERVER command was globbed!"
  FAILED=1
else
  echo "PASS: VPNCMD_SERVER command was NOT globbed (or no match found)"
fi

if [ $FAILED -eq 1 ]; then
  echo "Vulnerability confirmed or Test Failed"
  exit 1
else
  echo "All checks passed (Mocking behavior matches expectation for FIXED code? Or BROKEN?)"
  # Wait, if the code is BROKEN, the tests above should FAIL.
  # "PASS" above means the code behaves correctly.
  # So for reproduction, we expect FAIL.
fi
