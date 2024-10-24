#!/bin/zsh

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Function to set execution bit and make app readable by everyone
set_permissions() {
    local dir="$1"
    if [[ -d "$dir/Contents/MacOS" ]]; then
        echo "Processing: $dir/Contents/MacOS"
        chmod -R 755 "$dir/Contents/MacOS"
    fi
    chmod -R 755 "$dir"
}

# Export function to use with find
export -f set_permissions

# Find all .app directories starting from the root and set the appropriate permissions
find /Applications -type d -name "*.app" -exec zsh -c '
    set_permissions() {
        local dir="$1"
        if [[ -d "$dir/Contents/MacOS" ]]; then
            echo "Processing: $dir/Contents/MacOS"
            chmod -R 755 "$dir/Contents/MacOS"
            chmod +x "$dir/Contents/MacOS"
        fi
        chmod -R 755 "$dir"
    }
    set_permissions "$0"
' {} \;
