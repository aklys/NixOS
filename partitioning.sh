#!/bin/bash

# Test the basic syntax
set -e

# Test array declaration
readonly REQUIRED_COMMANDS=(
    "parted"
    "mkfs.fat"
)

# Test function syntax
check_required_commands() {
    echo "Testing function call"
    local missing_commands=()
    
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        echo "Checking: $cmd"
    done
    
    echo "Function works"
}

main() {
    echo "Starting main"
    check_required_commands
    echo "Main complete"
}

main "$@"
