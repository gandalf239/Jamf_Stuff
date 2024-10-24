#!/bin/bash

# Path to the target file
target_file=""

# Calculate the SHA-256 checksum
checksum=$(shasum -a 256 "$target_file" | awk '{ print $1 }')

# Write the checksum to a separate file
echo "" > ""

echo "SHA-256 checksum written to ${target_file}.sha256"
