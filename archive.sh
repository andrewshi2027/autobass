#!/bin/bash         

# [4] The script must have a --help or -h flag that prints usage instructions.

# Function to display help message
help_function() {
    echo "Usage: $0 [OPTIONS] SOURCE_DIR TARGET_DIR"
    echo ""
    echo "Create a timestamp backup of SOURCE_DIR in TARGET_DIR"
    echo ""
    echo "Options:"
    echo "  -h, --help"
    exit 1
}

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    help_function
    exit 0
fi



# ---------------------------------------------- NEW ----------------------------------------------
# Logging function
# - Writes to both terminal and archive.log
log_message() {
    # Log state: INFO, ERROR, etc...
    log_state="$1"                    
    # Log content: "archive started", etc...                         
    log_content="$2"                 
    # Timestamp: YYYY-MM-DD HH:MM:SS                          
    log_timestamp=$(date +"%Y-%m-%d %H:%M:%S") 
    # Formatted Message:
    log_formatted_message="$log_state: [$log_timestamp] $log_content"       

    # Output to the terminal
    echo "$log_formatted_message"

    # Append to archive.log file
    echo "$log_formatted_message" >> archive.log
}
# -------------------------------------------------------------------------------------------------




# It must accept two command-line arguments: a source directory, and a target directory.
# Check for correct number of arguments 
if [ "$#" -ne 2 ]; then
    echo "Error: Invalid number of arguments"
    help_function
    exit 1
fi

# Assign arguments to Variables
SOURCE_DIR="$1"          # First argument is the source directory
TARGET_DIR="$2"          # Second argument is the target directory




# ---------------------------------------------- NEW ----------------------------------------------

# Log script start
log_message "INFO" "archive script started."

# Tests if the source directory doesn't exist
if [[ ! -d "$SOURCE_DIR" ]]; then
    log_message "ERROR" "Source directory ($SOURCE_DIR) does not exist or is not readable. Exiting."
    exit 1
fi

# Tests if the source directory is readable
if [[ ! -r "$SOURCE_DIR" ]]; then 
    log_message "ERROR" "Source directory ($SOURCE_DIR) does not exist or is not readable. Exiting."
    exit 1
fi

# Check if target directory exists, if not then create it
if [[ ! -d "$TARGET_DIR" ]]; then
    if ! mkdir -p "$TARGET_DIR" 2>/dev/null; then
        log_message "ERROR" "Target directory ($TARGET_DIR) does not exist or could not be created. Exiting."
        exit 1
    fi
fi

# Check if target directory is writable
if [[ ! -w "$TARGET_DIR" ]]; then
    log_message "ERROR" "Target directory ($TARGET_DIR) does not exist or could not be created. Exiting."
    exit 1
fi

# Generate timestamp (format: YYYYMMDD_HHMMSS)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create archive file path (instead of backup directory)
ARCHIVE_FILE="$TARGET_DIR/backup_$TIMESTAMP.tar.gz"

# Record the backup action
log_message "INFO" "Backing up from $SOURCE_DIR to $ARCHIVE_FILE"

# Create compressed .tar.gz archive instead of copying files
# Step 1: Run the tar command and capture its exit status
tar -czf "$ARCHIVE_FILE" -C "$SOURCE_DIR" .
TAR_EXIT_CODE=$?

# Step 2: Check if the command succeeded
if [ $TAR_EXIT_CODE -eq 0 ]; then
    log_message "INFO" "Backup completed successfully."
else
    log_message "ERROR" "Backup failed during compression."
    exit 1
fi
# -------------------------------------------------------------------------------------------------

