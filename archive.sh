#!/bin/bash         

# Function to display help message
# - Explains what the script does
# - Shows available options and arguments
help_function() {
    echo "Usage: $0 [OPTIONS] [SOURCE_DIR] [TARGET_DIR]" # Display script usage
    echo ""
    echo "Create a timestamp backup of SOURCE_DIR in TARGET_DIR"
    echo ""
    echo "Arguments:"
    echo "  SOURCE_DIR   Source directory to backup (optional, uses config file default if not provided)"
    echo "  TARGET_DIR   Target directory for backups (optional, uses config file default if not provided)"
    echo ""
    echo "Options:"
    echo "  -h, --help   Show this help message"
    echo "  -d, --dry-run Show what would be backed up without performing the operation"
    echo ""
    echo "Configuration:"
    echo "  Default paths are read from archive.conf"
    echo "  Files matching patterns in .bassignore will be excluded from backups"
    exit 1
}

# DRY_RUN flag: prevents actual backup, just shows what would be done
# - Default: false (perform actual backup)
# - If user adds -d or --dry-run, set to true
DRY_RUN=false

# Input command line options
# - Help Flag
# - Dry-run Flag
# - Error, if user provides unknown options
while [[ $# -gt 0 ]]; do        # While there are arguments left to process
    case $1 in                  # Check the first argument ($1)
        # Help option
        -h|--help)
            help_function
            exit 0
            ;;
        # Dry-run option
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        # Unknown option
        -*)
            echo "Error: Unknown option $1"
            help_function
            exit 1
            ;;
        # Non-option arguments
        *)
            # Non-option arguments (SOURCE_DIR, TARGET_DIR)
            break
            ;;
    esac
done


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

# Source configuration file
CONFIG_FILE="archive.conf"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Warning: Configuration file ($CONFIG_FILE) not found. Command-line arguments required."
fi

# Arguments are now optional - if not provided, use values from config file
if [ "$#" -eq 0 ]; then
    # No arguments provided, use config file values
    if [[ -z "$SOURCE_DIR" || -z "$TARGET_DIR" ]]; then
        echo "Error: No command-line arguments provided and config file values are missing"
        help_function
        exit 1
    fi
    echo "Using configuration file defaults: SOURCE_DIR=$SOURCE_DIR, TARGET_DIR=$TARGET_DIR"
elif [ "$#" -eq 2 ]; then
    # Two arguments provided, use command-line arguments (override config)
    SOURCE_DIR="$1"          # First argument is the source directory
    TARGET_DIR="$2"          # Second argument is the target directory
    echo "Using command-line arguments: SOURCE_DIR=$SOURCE_DIR, TARGET_DIR=$TARGET_DIR"
else
    # Invalid number of arguments
    echo "Error: Invalid number of arguments. Provide either 0 arguments (use config) or 2 arguments (SOURCE_DIR TARGET_DIR)"
    help_function
    exit 1
fi


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



# Build Exclusion list (for tar)
# - Reads patterns from .bassignore
# - Skips blank lines and comments
# - Passes patterns to tar with --exclude options

# Start with empty exclusion list
EXCLUDE_OPTS=""               
# Set the default path of .bassignore to be in the source directory                  
BASSIGNORE_FILE="$SOURCE_DIR/.bassignore"   

# Check if .bassignore exists in the source directory, then in the current directory
if [[ -f "$BASSIGNORE_FILE" ]]; then    # If we found a file in source directory
    log_message "INFO" "Found .bassignore in source directory" # Read it line by line
    BASSIGNORE_PATH="$BASSIGNORE_FILE"
elif [[ -f ".bassignore" ]]; then       # if .bassignore doesn't exist in source, check current directory
    log_message "INFO" "Found .bassignore in current directory"
    BASSIGNORE_PATH=".bassignore"
else
    BASSIGNORE_PATH=""
fi

# Build exclusion options from .bassignore
if [[ -n "$BASSIGNORE_PATH" ]]; then        # -n means not empty 
    while IFS= read -r pattern; do          # Read line by line 
        # Skip empty lines and comments
        if [[ -n "$pattern" && ! "$pattern" =~ ^[[:space:]]*# ]]; then
            EXCLUDE_OPTS="$EXCLUDE_OPTS --exclude=$pattern" # Add exclude option
        fi
    done < "$BASSIGNORE_PATH"   # Input file is .bassignore
fi

# Dry-run functionality
# - Preview what would be backed up without creating the archive file
if [[ "$DRY_RUN" == "true" ]]; then
    log_message "INFO" "[DRY-RUN] Would backup from $SOURCE_DIR to $ARCHIVE_FILE"
    
    if [[ -n "$BASSIGNORE_PATH" ]]; then    # If we have exclusions
        log_message "INFO" "[DRY-RUN] Exclusion patterns from $BASSIGNORE_PATH:"
        while IFS= read -r pattern; do
            if [[ -n "$pattern" && ! "$pattern" =~ ^[[:space:]]*# ]]; then
                echo "  - $pattern" # Print each exclusion pattern
            fi
        done < "$BASSIGNORE_PATH"
    fi
    
    # Show include files
    log_message "INFO" "[DRY-RUN] Files that would be included:"
    tar -czf /dev/null -C "$SOURCE_DIR" $EXCLUDE_OPTS --verbose . 2>/dev/null || true
    # Run tar to list files, but output to /dev/null (no actual archive created)
    log_message "INFO" "[DRY-RUN] No actual backup performed"
    exit 0
fi

# Record the backup action
log_message "INFO" "Backing up from $SOURCE_DIR to $ARCHIVE_FILE"

if [[ -n "$BASSIGNORE_PATH" ]]; then
    log_message "INFO" "Applying exclusions from $BASSIGNORE_PATH"
fi

# Create compressed .tar.gz archive with exclusions
# Run the tar command and capture its exit status
tar -czf "$ARCHIVE_FILE" -C "$SOURCE_DIR" $EXCLUDE_OPTS .
# Capture exit code of tar command
TAR_EXIT_CODE=$?

# Check if the command succeeded
if [ $TAR_EXIT_CODE -eq 0 ]; then
    log_message "INFO" "Backup completed successfully."
# If tar failed, log error and exit with failure status
else
    log_message "ERROR" "Backup failed during compression."
    exit 1
fi

