# autobass - Automated Backup Archive Script

This project provides a flexible Bash script that automates the creation of compressed, timestamped archives.
It supports both command-line arguments and configuration files, allowing users to define source and target paths.
Exclusion patterns can be specified with a .bassignore file to skip unnecessary files or directories during backup.
A dry-run mode, detailed logging, and built-in error handling make it reliable for scheduled or manual archiving tasks.

## Installation

1. **Download the script:**
   ```bash
   git clone https://github.com/andrewshi2027/autobass.git
   cd autobass
   ```

2. **Make the script executable:**
   ```bash
   chmod +x archive.sh
   ```

3. **Fix line endings for cross-platform compatibility (required for Windows/WSL):**
   ```bash
   dos2unix archive.sh
   dos2unix archive.conf
   dos2unix .bassignore
   ```
   *Note: If `dos2unix` is not installed, use: `sudo apt install dos2unix`*

## Usage

### View Help
```bash
./archive.sh --help
```

### Using Configuration File (No Arguments)
```bash
# Uses default paths from archive.conf
./archive.sh
```

### Using Command-Line Arguments
```bash
# Backup specific directories
./archive.sh /path/to/source /path/to/target
# Example
./archive.sh ../test_source ../test_backup
```

### Dry-Run Mode (Preview Without Backing Up)
```bash
# Preview with config file defaults
./archive.sh --dry-run
./archive.sh -d

# Preview with specific directories
./archive.sh --dry-run /path/to/source /path/to/target
./archive.sh -d ../test_source ../test_backup
```

### Example Output
```
Using configuration file defaults: SOURCE_DIR=../test_source, TARGET_DIR=../test_backup
INFO: [2025-09-25 20:42:05] archive script started.
INFO: [2025-09-25 20:42:05] Found .bassignore in current directory
INFO: [2025-09-25 20:42:05] Backing up from ../test_source to ../test_backup/backup_20250925_204205.tar.gz
INFO: [2025-09-25 20:42:05] Applying exclusions from .bassignore
INFO: [2025-09-25 20:42:05] Backup completed successfully.
```

## Configuration

### Config File (`archive.conf`)
The configuration file contains default source and target directories:
```bash
# Archive Configuration File
# Default source directory to backup from
SOURCE_DIR="../test_source"

# Default target directory to backup to  
TARGET_DIR="../test_backup"
```

### Exclusion File (`.bassignore`)
Similar to `.gitignore`, this file contains patterns of files/directories to exclude from backups:
```bash
# Log files
*.log
*.out

# Temporary files
*.tmp
*.temp
tmp/
temp/

# System files
.DS_Store
Thumbs.db

# Version control
.git/
.svn/

# Build artifacts
*.o
*.class
build/
dist/

# Cache directories
node_modules/
.cache/
```

