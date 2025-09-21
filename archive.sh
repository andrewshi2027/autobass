#!/bin/bash         # The "shebang": tells the system to use bash to run this script


# Notes
# - Environment variables must be capitalized


# [1] It must accept two command-line arguments: (i) a source directory, and (ii) a target directory.

# Check for correct number of arguments 
if [ "$#" -ne 2 ]; then
    echo "Error: Invalid number of arguments"
    help_function
    exit 1
fi

# Assign arguments to Variables
SOURCE_DIR="$1"          # First argument is the source directory
TARGET_DIR="$2"          # Second argument is the target directory
