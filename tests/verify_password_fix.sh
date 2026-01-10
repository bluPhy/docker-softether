#!/bin/bash

# Mocking vpncmd_hub to check arguments
vpncmd_hub() {
  # In the real script: vpncmd_hub UserPasswordSet "$1" /PASSWORD:"$2"
  # $1 is username, $2 is password.
  # We want to verify that $2 contains the FULL password if it has spaces.

  if [ "$1" == "UserPasswordSet" ]; then
    # The real script call: vpncmd_hub UserPasswordSet "$1" /PASSWORD:"$2"
    # Arguments passed to vpncmd_hub:
    # $1 = "UserPasswordSet"
    # $2 = username
    # $3 = "/PASSWORD:password"

    local cmd="$1"
    local user="$2"
    local pass_arg="$3"

    echo "MOCK: vpncmd_hub received: 1='$1' 2='$2' 3='$3' 4='$4'"

    # Check if password matches expectation
    if [[ "$pass_arg" == "/PASSWORD:pass word" ]]; then
       echo "SUCCESS: Password passed correctly."
    elif [[ "$pass_arg" == "/PASSWORD:pass" ]]; then
       echo "FAILURE: Password truncated!"
       exit 1
    else
       echo "INFO: Password arg is '$pass_arg'"
    fi
  fi
}

# The adduser function from the script (simplified for testing)
adduser() {
  # printf " $1"
  # vpncmd_hub UserCreate "$1" /GROUP:none /REALNAME:none /NOTE:none
  vpncmd_hub UserPasswordSet "$1" /PASSWORD:"$2"
}

# Reproduction case
echo "--- Testing with spaces in password ---"
username="user1"
password="pass word"

# The problematic call in the original script:
# adduser $username $password

# We will test the behavior by calling it as the script does.
# If we want to verify the fix, we should invoke it properly.

# To verify the fix, we will define a function that wraps the logic we want to fix.

run_test() {
  local use_quotes=$1
  echo "Running test with quotes=$use_quotes"
  if [ "$use_quotes" == "yes" ]; then
      adduser "$username" "$password"
  else
      adduser $username $password
  fi
}

# Expect failure for no quotes
echo "Testing UNQUOTED (Original logic)..."
# Capture output to check for failure
if run_test "no" | grep -q "FAILURE"; then
   echo "Confirmed: Unquoted variable causes failure."
else
   echo "Unexpected: Unquoted variable passed?"
fi

# Expect success for quotes
echo "Testing QUOTED (Fix)..."
if run_test "yes" | grep -q "SUCCESS"; then
   echo "Confirmed: Quoted variable works."
else
   echo "Failed: Quoted variable did not work?"
   exit 1
fi
