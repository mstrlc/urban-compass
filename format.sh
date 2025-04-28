#!/bin/bash

# swiftformat
if ! command -v swiftformat &> /dev/null
then
    echo "swiftformat could not be found, please install it using 'brew install swiftformat'."
    exit 1
fi

# Define the directory to format (current directory by default)
DIR="${1:-.}"

# Find all Swift files in the directory and subdirectories
echo "Finding Swift files in '$DIR'..."
find "$DIR" -name "*.swift" -print0 | xargs -0 swiftformat

echo "Swift files formatted successfully."