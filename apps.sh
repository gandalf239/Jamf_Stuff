#!/bin/zsh

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Function to set permissions and ownership
set_default_permissions() {
    local dir="$1"
    
    echo "Processing directory: $dir"
    
    # Set ownership to root:wheel
    chown -R root:wheel "$dir"
    
    # Set directory permissions to 755
    find "$dir" -type d -exec chmod 755 {} \;
    
    # Set file permissions to 644
    find "$dir" -type f -exec chmod 644 {} \;
}

# Ensure the directory to process is provided as an argument
if [[ -z "$1" ]]; then
    echo "Usage: $0 /path/to/directory"
    exit 1
fi

# Set permissions and ownership for the specified directory
set_default_permissions "$1"

# Set ownership of the /Applications directory
sudo chown -R root:admin /Applications

# Set permissions for directories
sudo find /Applications -type d -exec chmod 775 {} \;

# Set permissions for files
sudo find /Applications -type f -exec chmod 664 {} \;

