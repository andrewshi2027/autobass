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

# [2] It must create a new folder in the target directory with a timestamp (e.g., backup_20250915_124506/).
# Generate timestamp (format: YYYYMMDD_HHMMSS)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create backup directory name
BACKUP_DIR="$TARGET_DIR/backup_$TIMESTAMP"          # Ex: /target_dir/backup_20250915_124506

# Create the backup directory
echo "Creating backup directory: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"                              # -p flag creates parent directories

# [3] It must copy all files from the source to this new target folder using rsync or cp.
echo "Copying files from $SOURCE_DIR to $BACKUP_DIR"
rsync -av "$SOURCE_DIR/" "$BACKUP_DIR/"
