#!/bin/bash

# Mock vpncmd_hub
vpncmd_hub() {
  echo "MOCK_VPNCMD_HUB: $@"
}

# Mock vpncmd_server
vpncmd_server() {
  echo "MOCK_VPNCMD_SERVER: $@"
}

adduser() {
  vpncmd_hub UserCreate "$1" /GROUP:none /REALNAME:none /NOTE:none
  vpncmd_hub UserPasswordSet "$1" /PASSWORD:"$2"
}

# Logic from copyables/entrypoint.sh (FIXED VERSION)

USERS="alice:secret pass;bob:another secret"

echo "--- Testing USERS processing ---"
if [[ $USERS ]]; then
  while IFS=';' read -ra USER; do
    for i in "${USER[@]}"; do
      IFS=':' read username password <<<"$i"
      # FIXED: Quoted arguments
      adduser "$username" "$password"
    done
  done <<<"$USERS"
fi

VPNCMD_SERVER="Cmd1 arg1;Cmd2 arg2"

echo "--- Testing VPNCMD_SERVER processing ---"
if [[ $VPNCMD_SERVER ]]; then
    while IFS=";" read -ra CMDS; do
      for cmd in "${CMDS[@]}"; do
        # FIXED: Loop over array
        echo "Processing cmd: '$cmd'"
        set -f
        vpncmd_server $cmd
        set +f
      done
    done <<<"$VPNCMD_SERVER"
fi

echo "--- Testing GLOB processing ---"
# Create a file that would match *
touch magic_file_glob_test
VPNCMD_SERVER="echo *"
if [[ $VPNCMD_SERVER ]]; then
    while IFS=";" read -ra CMDS; do
      for cmd in "${CMDS[@]}"; do
        # FIXED: Loop over array
        echo "Processing cmd: '$cmd'"
        set -f
        vpncmd_server $cmd
        set +f
      done
    done <<<"$VPNCMD_SERVER"
fi
rm magic_file_glob_test
