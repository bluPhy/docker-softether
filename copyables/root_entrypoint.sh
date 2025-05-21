#!/bin/bash
set -e

# Perform privileged operations
echo "Attempting to disable Transparent Huge Pages..."
if [ -w /sys/kernel/mm/transparent_hugepage/enabled ]; then
    echo never > /sys/kernel/mm/transparent_hugepage/enabled
    echo "Successfully disabled Transparent Huge Pages."
else
    echo "Warning: Could not disable Transparent Huge Pages. File not writable."
fi

echo "Attempting to set net.core.somaxconn..."
if sysctl -w net.core.somaxconn=16384; then
    echo "Successfully set net.core.somaxconn."
else
    echo "Warning: Could not set net.core.somaxconn."
fi

# The original entrypoint.sh already has an iptables check.
# It's non-fatal, so we can let it run as vpnuser if needed,
# or it can run here as root. Since it's just a check,
# let's keep it in the original entrypoint for now.

# Execute the original entrypoint as vpnuser
# The CMD from Dockerfile will be passed as "$@"
exec su-exec vpnuser /entrypoint.sh "$@"
