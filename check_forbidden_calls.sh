#!/bin/bash
# Usage: ./check_forbidden_calls.sh program_name malloc printf free exit

if [ "$#" -le 0 ]; then
    echo "Error: At least the program_name is required"
    exit 1
fi

program_name=$1
shift
authorized=("$@")

if [[ ! -f "$program_name" ]]; then
    echo "Error: '$program_name' not found."
    exit 1
fi

# Step 1: Get all undefined symbols (external function calls) and exclude authorized ones
if [ "$#" -gt 0 ]; then
	authorized_list=$(printf "%s\n" "${authorized[@]}")
	forbidden_calls=$(nm -u "$program_name" | awk '{print $2}' | grep -v '^_' | grep -vFf <(echo "$authorized_list"))
else
	forbidden_calls=$(nm -u "$program_name" | awk '{print $2}' | grep -v '^_')
fi

if [[ -z "$forbidden_calls" ]]; then
    echo "No forbidden function calls detected."
    exit 0
fi

echo "Forbidden function calls found:"
echo "$forbidden_calls"

# Step 2: Locate where each forbidden function is called
for func in $forbidden_calls; do
    # Normalize function name (strip any suffix like "@GLIBC" or "@plt")
    normalized_func=$(echo "$func" | sed 's/@.*//')

    echo ""
    echo "Checking for calls to forbidden function: $normalized_func ($func)"

    # Use objdump to find all references to the function in the binary
    objdump -d -l "$program_name" | grep "call.*<$normalized_func" | while read -r line; do
        # Extract the address of the call
        addr=$(echo "$line" | awk '/call/ {print $1}')
        if [[ -n "$addr" ]]; then
            # Resolve the address to a source file and line number
            addr2line -e "$program_name" "$addr"
        fi
    done
done
