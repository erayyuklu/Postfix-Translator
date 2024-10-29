#!/bin/bash

# Check if no arguments were provided
if [ $# -eq 0 ]; then
    echo "No arguments provided. Exiting."
    exit 1
fi

# Read the character from the first argument
char="$1"

# Convert the character to its ASCII value using printf
ascii_value=$(printf "%d" "'$char")
# Convert the ASCII value to hexadecimal
hex_value=$(printf "%x" "'$char")

# Output the ASCII and hexadecimal values
echo "The ASCII value of '$char' is $ascii_value"
echo "The hexadecimal value of '$char' is 0x$hex_value"
